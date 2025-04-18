import Database from "bun:sqlite";
import { test, expect } from "bun:test";

test("sqlite db", () => {
	const db = new Database(":memory:");
	db.exec(`CREATE TABLE tests (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);`);
	db.exec("INSERT INTO tests (name) VALUES ('a');");
	const result = db.query("SELECT * FROM tests").all();

	expect(result).toEqual([
		{
			id: 1,
			name: "a",
		},
	]);
});
