import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const source = readFileSync(
  new URL("../app/api/wolo/faucet/claim/route.ts", import.meta.url),
  "utf8",
);

test("DE mainnet faucet fails closed before any broadcast path", () => {
  const entrypoint = source.slice(source.indexOf("export async function POST("));
  assert.ok(entrypoint.startsWith("export async function POST("));
  const mainnetGuard = entrypoint.indexOf("if (isMainnetFaucetRuntime) {");
  const response = entrypoint.indexOf("return NextResponse.json(", mainnetGuard);
  const stop = entrypoint.indexOf("status: 503", response);
  const nextActivity = entrypoint.indexOf("const prisma = getPrisma()");
  const broadcast = entrypoint.indexOf("await sendFaucetTransfer(address)");
  assert.ok(mainnetGuard >= 0, "mainnet quarantine guard missing");
  assert.ok(response > mainnetGuard, "quarantine must directly return");
  assert.ok(stop > response && stop < nextActivity, "mainnet response must be 503");
  assert.ok(nextActivity > stop, "mainnet quarantine must happen before DB access");
  assert.ok(broadcast > nextActivity, "mainnet quarantine must precede MsgSend");
});

test("DE faucet mainnet quarantine cannot be enabled by an environment flag", () => {
  const entrypoint = source.slice(source.indexOf("export async function POST("));
  const guard = entrypoint.slice(0, entrypoint.indexOf("const prisma = getPrisma()"));
  assert.match(guard, /if \(isMainnetFaucetRuntime\) \{/);
  assert.doesNotMatch(guard, /process\.env\./);
  assert.match(guard, /pending security review/);
});

test("The old direct CLI broadcast remains identified for security review", () => {
  assert.match(source, /execFileAsync\(FAUCET_CLI, txArgs/);
  assert.match(source, /MAINNET_FAUCET_HOME/);
  assert.match(source, /await sendFaucetTransfer\(address\)/);
});
