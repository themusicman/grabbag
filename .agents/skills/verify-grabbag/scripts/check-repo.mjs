#!/usr/bin/env node
// Check the invariants that grabbag's vendoring metadata promises.
// Usage: check-repo.mjs [--root DIR] [--base REF]
//   --root  checkout to check (default: the git checkout this script is in)
//   --base  also check that skills changed since REF have a CHANGELOG.md entry
// Prints one line per failed invariant and a summary. Exit 0 when all pass.
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

const args = process.argv.slice(2);
const opt = (name) => {
  const i = args.indexOf(name);
  return i === -1 ? undefined : args[i + 1];
};
const here = path.dirname(new URL(import.meta.url).pathname);
const root = path.resolve(
  opt("--root") ?? execFileSync("git", ["-C", here, "rev-parse", "--show-toplevel"], { encoding: "utf8" }).trim(),
);
const base = opt("--base");

const failures = [];
const passed = new Set();
const checks = new Set();
const fail = (check, message) => failures.push({ check, message });
const run = (check, fn) => {
  checks.add(check);
  const before = failures.length;
  fn();
  if (failures.length === before) passed.add(check);
};

const read = (rel) => fs.readFileSync(path.join(root, rel), "utf8");
const exists = (rel) => fs.existsSync(path.join(root, rel));

const folders = fs
  .readdirSync(path.join(root, "skills"), { withFileTypes: true })
  .filter((d) => d.isDirectory())
  .map((d) => d.name)
  .sort();
const sources = JSON.parse(read("sources.json"));
const skillEntries = sources.filter((s) => s.kind === "skill");
const agentEntries = sources.filter((s) => s.kind === "agent");
const entryOf = new Map(skillEntries.map((s) => [s.name, s]));

const frontmatter = (text) => {
  const m = /^---\n([\s\S]*?)\n---\n/.exec(text);
  if (!m) return undefined;
  const fields = {};
  for (const line of m[1].split("\n")) {
    const kv = /^([A-Za-z_-]+):\s*(.*)$/.exec(line);
    if (kv) fields[kv[1]] = kv[2].replace(/^"(.*)"$/, "$1");
  }
  return fields;
};

// SOURCE.md blocks: the skill's own block, then one per "## Bundled agent".
const sourceBlocks = (text) =>
  text.split(/^## Bundled agent.*$/m).map((block) => {
    const fields = {};
    for (const m of block.matchAll(/^- ([A-Za-z ]+): (.*)$/gm)) fields[m[1]] = m[2].replace(/^`(.*)`$/, "$1");
    const copyright = /Copyright \(c\) ([^.]+(?:\.[^ .][^.]*)*)\./.exec(block)?.[1];
    return { fields, copyright };
  });

run("skill-files", () => {
  for (const name of folders)
    for (const file of ["SKILL.md", "SOURCE.md"])
      if (!exists(`skills/${name}/${file}`)) fail("skill-files", `skills/${name}/ has no ${file}`);
});

run("frontmatter", () => {
  for (const name of folders) {
    if (!exists(`skills/${name}/SKILL.md`)) continue;
    const fm = frontmatter(read(`skills/${name}/SKILL.md`));
    if (!fm) fail("frontmatter", `skills/${name}/SKILL.md has no YAML frontmatter`);
    else {
      if (fm.name !== name) fail("frontmatter", `skills/${name}/SKILL.md name is "${fm.name}", folder is "${name}"`);
      if (!fm.description) fail("frontmatter", `skills/${name}/SKILL.md has no description`);
    }
  }
});

run("sources-json", () => {
  const seen = new Set();
  for (const s of sources) {
    const key = `${s.kind}:${s.name}`;
    if (seen.has(key)) fail("sources-json", `sources.json lists ${key} twice`);
    seen.add(key);
    if (!/^[0-9a-f]{40}$/.test(s.upstream_sha ?? ""))
      fail("sources-json", `sources.json ${key} upstream_sha is not a 40-hex commit: ${s.upstream_sha}`);
    if (typeof s.modified !== "boolean") fail("sources-json", `sources.json ${key} modified is not a boolean`);
  }
  const listed = new Set(skillEntries.map((s) => s.name));
  for (const name of folders) if (!listed.has(name)) fail("sources-json", `skills/${name}/ is not in sources.json`);
  for (const s of skillEntries) {
    if (!folders.includes(s.name)) fail("sources-json", `sources.json lists skill ${s.name}, but skills/${s.name}/ does not exist`);
    if (s.local_path !== `skills/${s.name}`)
      fail("sources-json", `sources.json skill ${s.name} local_path is ${s.local_path}, expected skills/${s.name}`);
  }
  for (const a of agentEntries)
    if (!/^skills\/[^/]+\/agents\/[^/]+\.md$/.test(a.local_path) || !exists(a.local_path))
      fail("sources-json", `sources.json agent ${a.name} local_path ${a.local_path} is not an existing skills/<skill>/agents/*.md file`);
});

run("source-md", () => {
  const compare = (where, fields, s) => {
    const want = {
      Name: s.name,
      Kind: s.kind,
      "Source repo": `https://github.com/${s.source_repo}`,
      "Source path": s.source_path,
      "Upstream commit": s.upstream_sha,
      "Local path": s.local_path,
      Modified: s.modified ? "yes" : "no",
    };
    for (const [k, v] of Object.entries(want))
      if (fields[k] !== v) fail("source-md", `${where} "${k}" is ${JSON.stringify(fields[k])}, sources.json says ${JSON.stringify(v)}`);
  };
  for (const s of skillEntries) {
    if (!exists(`${s.local_path}/SOURCE.md`)) continue;
    const blocks = sourceBlocks(read(`${s.local_path}/SOURCE.md`));
    compare(`${s.local_path}/SOURCE.md`, blocks[0].fields, s);
  }
  for (const a of agentEntries) {
    const owner = a.local_path.split("/").slice(0, 2).join("/");
    const block = exists(`${owner}/SOURCE.md`)
      ? sourceBlocks(read(`${owner}/SOURCE.md`)).find((b) => b.fields.Name === a.name)
      : undefined;
    if (!block) fail("source-md", `${owner}/SOURCE.md has no "## Bundled agent" block for ${a.name}`);
    else compare(`${owner}/SOURCE.md (agent ${a.name})`, block.fields, a);
  }
});

run("changelog", () => {
  for (const s of skillEntries) {
    const has = exists(`${s.local_path}/CHANGELOG.md`);
    if (s.modified && !has) fail("changelog", `${s.name} is modified in sources.json but has no CHANGELOG.md`);
    if (!s.modified && has) fail("changelog", `${s.name} has a CHANGELOG.md but sources.json says modified: false`);
  }
  for (const a of agentEntries) {
    if (!a.modified) continue;
    const owner = a.local_path.split("/").slice(0, 2).join("/");
    const log = exists(`${owner}/CHANGELOG.md`) ? read(`${owner}/CHANGELOG.md`) : "";
    if (!log.includes(path.basename(a.local_path)))
      fail("changelog", `agent ${a.name} is modified, but ${owner}/CHANGELOG.md does not mention ${path.basename(a.local_path)}`);
  }
});

run("readme", () => {
  const readme = read("README.md");
  const section = (title) => readme.split(/^## /m).find((s) => s.startsWith(`${title}\n`)) ?? "";
  const rows = (text) =>
    [...text.matchAll(/^\| \[([^\]]+)\]\(([^)]+)\) \| \[[^\]]*\]\(([^)]+)\) \|$/gm)].map((m) => ({
      name: m[1],
      local: m[2],
      upstream: m[3],
    }));
  const checkRows = (title, entries) => {
    const found = rows(section(title));
    const names = found.map((r) => r.name);
    for (const s of entries) {
      const row = found.find((r) => r.name === s.name);
      if (!row) {
        fail("readme", `README.md ${title} table has no row for ${s.name}`);
        continue;
      }
      if (row.local !== s.local_path) fail("readme", `README.md row ${s.name} links ${row.local}, expected ${s.local_path}`);
      const want = `https://github.com/${s.source_repo}/${s.kind === "agent" ? "blob" : "tree"}/${s.upstream_sha}/${s.source_path}`;
      if (row.upstream !== want) fail("readme", `README.md row ${s.name} links ${row.upstream}, expected ${want}`);
    }
    for (const n of names)
      if (!entries.some((s) => s.name === n)) fail("readme", `README.md ${title} table lists ${n}, which sources.json does not`);
    if (new Set(names).size !== names.length) fail("readme", `README.md ${title} table has a duplicate row`);
  };
  checkRows("Skills", skillEntries);
  checkRows("Agents", agentEntries);
});

run("notice", () => {
  const notice = read("NOTICE");
  const sections = notice.split(/^(?=Skills from )/m).slice(1);
  for (const s of sources) {
    const top = s.source_path.split("/")[0];
    const header = `Skills from \`${s.source_repo}\` (\`${top}/\`)`;
    const section = sections.find((t) => t.startsWith(header));
    if (!section) {
      fail("notice", `NOTICE has no "${header}" section for ${s.kind} ${s.name}`);
      continue;
    }
    const holder = /Copyright \(c\) \d{4} (.+)/.exec(section)?.[1]?.trim();
    const owner = s.kind === "agent" ? s.local_path.split("/").slice(0, 2).join("/") : s.local_path;
    if (s.kind === "skill" && exists(`${owner}/SOURCE.md`)) {
      const claimed = sourceBlocks(read(`${owner}/SOURCE.md`))[0].copyright?.replace(/^\d{4} /, "");
      if (claimed !== holder)
        fail("notice", `${owner}/SOURCE.md names copyright holder "${claimed}", NOTICE section "${header}" names "${holder}"`);
    }
  }
});

if (base) {
  run("changed-skills", () => {
    const git = (...a) => execFileSync("git", ["-C", root, ...a], { encoding: "utf8" });
    // Committed changes since the merge base, plus staged, unstaged, and untracked files.
    const changed = new Set(
      [
        ...git("diff", "--name-only", `${base}...HEAD`).split("\n"),
        ...git("diff", "--name-only", "HEAD").split("\n"),
        ...git("ls-files", "--others", "--exclude-standard", "skills").split("\n"),
      ].filter((f) => f.startsWith("skills/")),
    );
    let baseSources = [];
    try {
      baseSources = JSON.parse(git("show", `${base}:sources.json`));
    } catch {}
    const touched = new Map();
    for (const f of changed) {
      const [, name, ...rest] = f.split("/");
      if (!touched.has(name)) touched.set(name, []);
      touched.get(name).push(rest.join("/"));
    }
    for (const [name, files] of touched) {
      const before = baseSources.find((s) => s.kind === "skill" && s.name === name);
      const now = entryOf.get(name);
      if (!before || !now) continue; // a new or removed skill is checked by the other invariants
      if (before.upstream_sha !== now.upstream_sha) continue; // re-vendored from upstream
      const content = files.filter((f) => f !== "SOURCE.md" && f !== "CHANGELOG.md");
      if (!content.length) continue;
      if (!files.includes("CHANGELOG.md"))
        fail("changed-skills", `skills/${name}/ changed since ${base} (${content.join(", ")}) but its CHANGELOG.md did not`);
      if (!now.modified) fail("changed-skills", `skills/${name}/ changed since ${base} but sources.json still says modified: false`);
    }
  });
}

for (const f of failures) console.log(`FAIL ${f.check}: ${f.message}`);
console.log(
  `${root}: ${folders.length} skill folders, ${skillEntries.length} skills and ${agentEntries.length} agents in sources.json`,
);
console.log(`checks passed: ${[...passed].join(", ") || "none"}`);
const failed = [...checks].filter((c) => !passed.has(c));
console.log(failures.length ? `checks failed: ${failed.join(", ")} (${failures.length} problems)` : "PASS");
process.exit(failures.length ? 1 : 0);
