const {readFileSync, writeFileSync} = require("fs");
const wabt = require("wabt")();
const path = require("path");

module.exports = function(inputWat, outputWasm){
	// @filename: string,
	// @buffer: string | Uint8Array, 
	// @options?
	// : WasmFeatures
	const wasmModule = wabt.parseWat(inputWat, readFileSync(inputWat, "utf8"));
	const {buffer} = wasmModule.toBinary({write_debug_name: true});
	writeFileSync(outputWasm, new Buffer(buffer))
}