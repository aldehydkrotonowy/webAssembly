(module
(memory $mem 1)
	(func $helloworld (result i32)
		(i32.const 42)
	)

	(func $NG_left_shift (param $value i32)(result i32)
		(i32.shl
			(get_local $value)
			(i32.const 1)
		)
	)

	(table 18 anyfunc)
	(elem (i32.const 0)
		;;dead cells
		$dead
		$dead
		$dead
		$alive
		$dead
		$dead
		$dead
		$dead
		$dead
		;;alive cells
		$dead
		$dead
		$alive
		$alive
		$dead
		$dead
		$dead
		$dead
		$dead
	)

	(func $alive (result i32)
		i32.const 1
	)

	(func $dead (result i32)
		i32.const 0
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

	(func $inRange (param $low i32) (param $high i32) (param $value i32) (result i32)
		(i32.and
			(i32.ge_s (get_local $value) (get_local $low))
			(i32.lt_s (get_local $value) (get_local $high))
		)
	)
 
 	(func $setCellStateForNextGeneration (param $x i32)(param $y i32)(param $value i32)
		(call $setCell
			(get_local $x)
			(get_local $y)
			(i32.or
				(call $isCellAlive
					(get_local $x)
					(get_local $y)
				)
				(i32.shl
					(get_local $value)
					(i32.const 1)
				)
			)
		)
	)

	(func $getCell_2 (param $x i32) (param $y i32) (result i32)
		(if (result i32)
			(block (result i32)
				(i32.and
					(call $inRange (i32.const 0)(i32.const 50)(get_local $x))
					(call $inRange (i32.const 0)(i32.const 50)(get_local $y))
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
	)

	(func $increment (param $value i32) (result i32)
    (i32.add 
      (get_local $value)
      (i32.const 1)
    )
  )

	(func $evolveCellToNextGeneration (param $x i32) (param $y i32)
    (call $setCellStateForNextGeneration
      (get_local $x)
      (get_local $y)
      (call_indirect (result i32)
        (i32.or
          (i32.mul
            (i32.const 9)
            (call $isCellAlive
              (get_local $x)
              (get_local $y)
            )
          )
          (call $liveNeighbourCount
            (get_local $x)
            (get_local $y)
          )
        )
      )
    )
  )

	(func $evolveAllCells
    (local $x i32)
    (local $y i32)

    (set_local $y (i32.const 0))
    
    (block 
      (loop 

        (set_local $x (i32.const 0))

        (block 
          (loop 
            ;; (call $log
            ;;   (get_local $x)
            ;;   (get_local $y)
            ;; )
            (call $evolveCellToNextGeneration
              (get_local $x)
              (get_local $y)
            )
            (set_local $x (call $increment (get_local $x)))
            (br_if 1 (i32.eq (get_local $x) (i32.const 50)))
            (br 0)
          )
        )
        
        (set_local $y (call $increment (get_local $y)))
        (br_if 1 (i32.eq (get_local $y) (i32.const 50)))
        (br 0)
      )
    )
  )

  (func $promoteNextGeneration
    (local $x i32)
    (local $y i32)

    (set_local $y (i32.const 0))
    
    (block 
      (loop 

        (set_local $x (i32.const 0))

        (block 
          (loop
            (call $setCell
              (get_local $x)
              (get_local $y)
              (i32.shr_u
                (call $getCell
                  (get_local $x)
                  (get_local $y)
                )
                (i32.const 1)
              )
            )

            (set_local $x (call $increment (get_local $x)))
            (br_if 1 (i32.eq (get_local $x) (i32.const 50)))
            (br 0)
          )
        )
        
        (set_local $y (call $increment (get_local $y)))
        (br_if 1 (i32.eq (get_local $y) (i32.const 50)))
        (br 0)
      )
    )
  )

	(func $tick
    (call $evolveAllCells)
    (call $promoteNextGeneration)
  )

	(export "helloworld" (func $helloworld))
	(export "NG_left_shift" (func $NG_left_shift))
	(export "offsetFromCoordinates" (func $offsetFromCoordinate))
	(export "offsetFromCoordinates2" (func $offsetFromCoordinate2))
	(export "setCell" (func $setCell))
	(export "getCell" (func $getCell))
  (export "isCellAlive" (func $isCellAlive))
  (export "inRange" (func $inRange))
  (export "setCellStateForNextGeneration" (func $setCellStateForNextGeneration))
	(export "liveNeighbourCount" (func $liveNeighbourCount))
  (export "promoteNextGeneration" (func $promoteNextGeneration))
  (export "evolveAllCells" (func $evolveAllCells))
  (export "evolveCellToNextGeneration" (func $evolveCellToNextGeneration))
	(export "memory" (memory $mem))
	(export "tick" (func $tick))
)