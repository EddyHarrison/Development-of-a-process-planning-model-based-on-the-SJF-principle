import algorithm

type
    Process* = tuple
        PID: int
        arrivalTime: int
        burstTime: int
    TableProcesses* = seq[Process]

    ResultProcess* = tuple
        PID: int
        completionTime: int
        turnAroundTime: int
        waitingTime: int
    TableResult* = seq[ResultProcess]

proc cmp(process1, process2: Process): int =
    result = cmp(process1.burstTime, process2.burstTime)

proc indexMinArrivalTime(processes: TableProcesses): int =
    if len(processes) == 0:
        return -1

    result = 0
    
    for index in 1 ..< len(processes):
        if processes[index].arrivalTime < processes[result].arrivalTime:
            result = index

proc proscessingSJF*(processes: TableProcesses): TableResult =
    result = @[]

    var
        time: int = 0
        priorityProcesses: TableProcesses = processes.sorted(cmp)
        way: TableProcesses = @[]
        wasAdded: bool

    while len(priorityProcesses) != 0:
        wasAdded = false

        for index in 0 ..< len(priorityProcesses):
            if priorityProcesses[index].arrivalTime <= time:
                time += priorityProcesses[index].burstTime

                way.add(priorityProcesses[index])
                priorityProcesses.delete(index)
                
                wasAdded = true
                break
        
        if not wasAdded:
            time = priorityProcesses[indexMinArrivalTime(priorityProcesses)].arrivalTime
 
    var
        tempResultProcess: ResultProcess
    
    time = 0

    for index in 0 ..< len(way):
        if way[index].arrivalTime > time:
            time = way[index].arrivalTime
        
        time += way[index].burstTime

        tempResultProcess = (
            PID: way[index].PID,
            completionTime: time,
            turnAroundTime: time - way[index].arrivalTime,
            waitingTime: time - way[index].arrivalTime - way[index].burstTime
        )

        result.add(tempResultProcess)
