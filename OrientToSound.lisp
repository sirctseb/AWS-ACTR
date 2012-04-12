(clear-all)

(define-model count
	(sgp :es t :lf .05 :trace-detail high)

	(chunk-type count-order first second)
	(chunk-type count-from start end count)

	(add-dm
		(b ISA count-order first 1 second 2)
		(c ISA count-order first 2 second 3)
	)
)