(module
  (import "js" "mem" (memory 1))
  (func $encode_cp (param $cp i32) (param $dest i32) (result i32)
    (local $last i32)
    (local $middle i32)
	
    local.get $cp
    i32.const 0x80
    i32.lt_u
    (if
      (then
	local.get $dest
	local.get $cp
	i32.store8
	i32.const 1
	return
      )
    )

    local.get $cp
    i32.const 0x3F
    i32.and
    i32.const 0x80
    i32.add
    local.set $last
    local.get $cp
    i32.const 0x800
    i32.lt_u
    (if
      (then
	(i32.store8 (i32.add (local.get $dest) (i32.const 1)) (local.get $last))
	(i32.store8 (local.get $dest) (i32.add (i32.shr_u (local.get $cp) (i32.const 6)) (i32.const 0xC0)))
	i32.const 2
	return
      )
    )

    (i32.add (i32.and (i32.shr_u (local.get $cp) (i32.const 6)) (i32.const 0x3F)) (i32.const 0x80))
    local.set $middle
    (i32.lt_u (local.get $cp) (i32.const 0x010000))
    (if
      (then
	(i32.store8 (i32.add (local.get $dest) (i32.const 2)) (local.get $last))
	(i32.store8 (i32.add (local.get $dest) (i32.const 1)) (local.get $middle))
	(i32.store8 (local.get $dest) (i32.add (i32.shr_u (local.get $cp) (i32.const 12)) (i32.const 0xE0)))
	i32.const 3
	return
      )
    )

    (call $encode_cp (i32.const 0xFFFD) (local.get $dest))
  )
  (func $encode (export "encode") (param $src i32) (param $dest i32)
    (local $i i32)
    (local $j i32)
    (local $c i32)

    (local.set $i (i32.const 0))
    (local.set $j (i32.const 0))

    (loop $myloop (block $breakloop
      (i32.load8_u (i32.add (local.get $src) (local.get $i)))
      local.tee $c
      i32.eqz
      br_if $breakloop
      (call $encode_cp (i32.add (local.get $c) (i32.const 0x1F4C0)) (i32.add (local.get $dest) (local.get $j)))
      local.get $j
      i32.add
      local.set $j
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      br $myloop
    ))
    
    (i32.store8 (i32.add (local.get $dest) (local.get $j)) (i32.const 0))
  )
)
