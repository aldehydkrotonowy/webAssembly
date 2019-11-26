(module
(memory $mem 1)
	(func (result i32)
		(i32.const 42)
	)

	(func $offsetFromCoordinate (param $x i32)(param $y i32)(result i32)
		(i32.add
			(i32.mul
				(i32.const 200)
				(get_local $y)
			)
			(i32.mul
				(i32.const 4)
				(get_local $x)
			)
		)
	)

	(func $offsetFromCoordinate2 (param $x i32)(param $y i32)(result i32)
		get_local $y
		i32.const 50
		i32.mul
		get_local $x
		i32.add
		i32.const 4
		i32.mul	
	)

	(func $setCell (param $x i32) (param $y i32) (param $value i32)
		get_local $y
		get_local $x
		call $offsetFromCoordinate
		get_local $value
		i32.store
	)

	(func $getCell (param $x i32) (param $y i32) (result i32)
		get_local $y
		get_local $x
		call $offsetFromCoordinate
		i32.load
	) 

	(func $liveNeighbourCount (param $x i32) (param $y i32) (result i32)
		i32.const 0
		;; x+1,y
		get_local $x
		i32.const 1
		i32.add
		get_local $y
		call $isCellAlive
		i32.add

		;;x-1,y
		get_local $x
		i32.const -1
		i32.add
		get_local $y
		call $isCellAlive
		i32.add

		;;x, y+1
		get_local $x
		get_local $y
		i32.const 1
		i32.add
		call $isCellAlive
		i32.add

		;;x, y-1
		get_local $x
		get_local $y
		i32.const -1
		i32.add
		call $isCellAlive
		i32.add

		;;x-1, y+1
		get_local $x
		i32.const -1
		i32.add
		get_local $y
		i32.const 1
		i32.add
		call $isCellAlive
		i32.add

		;;x-1, y-1
		get_local $x
		i32.const -1
		i32.add
		get_local $y
		i32.const -1
		i32.add
		call $isCellAlive
		i32.add

		;;x+1, y+1
		get_local $x
		i32.const 1
		i32.add
		get_local $y
		i32.const 1
		i32.add
		call $isCellAlive
		i32.add

		;;x+1, y-1
		get_local $x
		i32.const 1
		i32.add
		get_local $y
		i32.const -1
		i32.add
		call $isCellAlive
		i32.add
	)

	(func $isCellAlive (param $x i32) (param $y i32) (result i32)
		get_local $y
		get_local $x
		call $getCell
		i32.const 1
		i32.and
	)

	(func $inRange (param $low i32) (param $high) (param $value i32) (result i32)
		(i32.and
			(i32.ge_s (get_local $value) (get_local $low))
			(i32.lt_s (get_local $value) (get_local $high))
		)
	)

	(func $getCell_2 (param $x i32) (param $y i32) (result i32)
		(if (result i32)
			(block (result i32)
				(i32.and
					(call $inRange
						(i32.const 0)
						(i32.const 50)
						(get_local $x)
					)
					(call $inRange
						(i32.const 0)
						(i32.const 50)
						(get_local $y)
					)
				)
			)
		)
		(then
			(i32.load
				(call $offsetFromCoordinate
					(get_local $x)
					(get_local $y)
				)
			)
		)
		(else
		 (i32.const 0)
		)
	)

	(export "helloworld" (func 0))
	(export "liveNeighbourCount" (func $liveNeighbourCount))
	(export "offsetFromCoordinates" (func $offsetFromCoordinate))
	(export "offsetFromCoordinates2" (func $offsetFromCoordinate2))
	(export "setCell" (func $setCell))
	(export "getCell" (func $getCell))
	(export "memory" (memory $mem))
)