import SJF

proc main =
    var processes: TableProcesses = @[
        (1, 2, 1),
        (2, 1, 5),
        (3, 4, 1),
        (4, 0, 6),
        (5, 2, 3),
    ]

    echo proscessingSJF(processes)

when isMainModule:
    main()
