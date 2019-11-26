const {readFileSync} = require("fs");

module.exports = async function instantiate(inputWasm) {
	const buffer = readFileSync(inputWasm);
	const module = await WebAssembly.compile(buffer);
	const instance = await WebAssembly.instantiate(module);

	return instance.exports;
}