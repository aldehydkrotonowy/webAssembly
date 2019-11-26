const build = require("./wat-to-wasm");
const instantiate = require("./instanceCreator");

let wasm;

beforeAll(() => {
	build("main.wat", "main.wasm");
})

beforeEach(async done => {
	wasm = await instantiate("main.wasm");
	done();
})

test('helloworld return 42', () => {
	expect(wasm.helloworld()).toBe(42);
});

test("offsetFromCoordinates", () => {
	expect(wasm.offsetFromCoordinates(0,0)).toBe(0);
	expect(wasm.offsetFromCoordinates(49,0)).toBe(49*4);
	expect(wasm.offsetFromCoordinates(10,2)).toBe((10+2*50)*4);
});

test("offsetFromCoordinates2", () => {
	expect(wasm.offsetFromCoordinates(0,0)).toBe(0);
	expect(wasm.offsetFromCoordinates(49,0)).toBe(49*4);
	expect(wasm.offsetFromCoordinates(10,2)).toBe((10+2*50)*4);
});

test("set / get cell", () => {
	expect(wasm.getCell(2,2)).toBe(0);
	expect(wasm.getCell(3,2)).toBe(0);
	expect(wasm.getCell(6,8)).toBe(0);
	wasm.setCell(2,2,1);
	wasm.setCell(3,2,1);
	wasm.setCell(6,8,1)
	expect(wasm.getCell(2,2)).toBe(1);
	expect(wasm.getCell(3,2)).toBe(1);
	expect(wasm.getCell(6,8)).toBe(1);
})

test("set cells does not leak to neighbours", () => {
	wasm.setCell(2,2,1);
	expect(wasm.getCell(3,2)).toBe(0);
	expect(wasm.getCell(1,2)).toBe(0);
})

test("memory starts in and empty state", () => {
	for(let x = 0; x<49; x++){
		for(let y = 0; y<49; y++){
			expect(wasm.getCell(x,y)).toBe(0);
		}
	}
})

test("read memory directyl", () => {
	const memory = new Uint32Array(wasm.memory.buffer, 0, 50*50);
	wasm.setCell(2,2,10);
	expect(memory[2 + 2 * 50]).toBe(10);
	expect(memory[3+2*50]).toBe(0);
})

test("without boundary values", () => {
	expect(wasm.liveNeighbourCount(2,2)).toBe(0);
	wasm.setCell(1,1,1);
	expect(wasm.liveNeighbourCount(2,2)).toBe(1);
	wasm.setCell(2,1,1);
	expect(wasm.liveNeighbourCount(2,2)).toBe(2);
	wasm.setCell(3,1,1);
	expect(wasm.liveNeighbourCount(2,2)).toBe(3);
	wasm.setCell(1,2,1);
	expect(wasm.liveNeighbourCount(2,2)).toBe(4);
	wasm.setCell(3,2,1);
	expect(wasm.liveNeighbourCount(2,2)).toBe(5);
	wasm.setCell(1,3,1);
	expect(wasm.liveNeighbourCount(2,2)).toBe(6);
	wasm.setCell(2,3,1);
	expect(wasm.liveNeighbourCount(2,2)).toBe(7);
	wasm.setCell(3,3,1);
	expect(wasm.liveNeighbourCount(2,2)).toBe(8);
})