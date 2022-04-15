import gintro/[gtk4, gobject, cairo]

import std/algorithm
import std/sets
import std/sequtils
import std/stats

import SJF

type
    DrawingSJFDialog* = ref object of Dialog
        tableResult: TableResult
        drawingProcesses: DrawingArea
        choosingMode: ComboBoxText

proc changedMode(choosingMode: ComboBoxText, drawingSJFDialog: DrawingSJFDialog) =
    queueDraw(drawingSJFDialog.drawingProcesses)

proc remapRange[T: SomeNumber](number, fromOld, toOld, fromNew, toNew: T): T =
    return ((number - fromOld) / (toOld - fromOld) * (toNew - fromNew).float).T + fromNew

template showCenterText(context: Context, text: string, sizeFont: float, coordinateX, coordinateY: float, textExtents: TextExtents) =
    context.setFontSize(sizeFont)
    context.textExtents(text, textExtents)
    context.moveTo(coordinateX, coordinateY)
    context.showText(text)
    

proc drawProcesses(drawingProcesses: DrawingArea; context: Context, width: int, height: int, drawingSJFDialog: DrawingSJFDialog) =
    if len(drawingSJFDialog.tableResult) == 0:
        return
    
    let
        choiseMode: int = drawingSJFDialog.choosingMode.getActive()
        coefficientSize: float = min(width, height).float / 240

    var
        textExtents: TextExtents
        nextYspecText: float = 10 * coefficientSize

    context.setSource(0.0, 0.0, 0.0) # black
    context.setLineWidth(1 * coefficientSize)
    
    case choiseMode:
        of 0:
            let
                minTime: int =  min(drawingSJFDialog.tableResult.mapIt(it.completionTime - (it.turnAroundTime - it.waitingTime)))
                maxTime: int = max(drawingSJFDialog.tableResult.mapIt(it.completionTime))
                processLineWidth: float = 90.0
                processLineHeight: float = 30.0
                processLineBorders: array[4, float] = [
                    remapRange((100.0 - processLineWidth) / 2, 0.0, 100.0, 0.0, width.float),
                    remapRange((100.0 - processLineHeight) / 2, 0.0, 100.0, 0.0, height.float),
                    remapRange((100.0 - processLineWidth) / 2 + processLineWidth, 0.0, 100.0, 0.0, width.float),
                    remapRange((100.0 - processLineHeight) / 2 + processLineHeight, 0.0, 100.0, 0.0, height.float)
                ]
                textTotalTime = "Total time = " & $(maxTime)
                textAverageWaitTime = "Average wait time = " & $(mean(drawingSJFDialog.tableResult.mapIt(it.waitingTime)))
            
            var
                tempTable: ResultProcess
                firstPositionX: int
                secondPositionX: int
                firstCoordinateX: float
                secondCoordinateX: float
                textNameProcess: string
                textStartProcess: string
                textEndProcess: string

            
            context.rectangle(
                processLineBorders[0],
                processLineBorders[1],
                processLineBorders[2] - processLineBorders[0],
                processLineBorders[3] - processLineBorders[1]
            )
            context.stroke()
            
            for index in 0 ..< len(drawingSJFDialog.tableResult):
                tempTable = drawingSJFDialog.tableResult[index]

                firstPositionX = tempTable.completionTime - (tempTable.turnAroundTime - tempTable.waitingTime)
                secondPositionX = tempTable.completionTime

                textNameProcess = "P" & $tempTable.PID
                textStartProcess = $firstPositionX
                textEndProcess = $secondPositionX

                firstCoordinateX = remapRange(firstPositionX.float, minTime.float, maxTime.float, processLineBorders[0], processLineBorders[2])
                secondCoordinateX = remapRange(secondPositionX.float, minTime.float, maxTime.float, processLineBorders[0], processLineBorders[2])

                context.rectangle(
                    firstCoordinateX,
                    processLineBorders[1],
                    secondCoordinateX - firstCoordinateX,
                    processLineBorders[3] - processLineBorders[1]
                )
                context.stroke()

                showCenterText(
                    context = context,
                    text = textNameProcess,
                    sizeFont = 16 * coefficientSize,
                    coordinateX = (firstCoordinateX + (secondCoordinateX - firstCoordinateX) / 2) - (textExtents.width / 2 + textExtents.xBearing),
                    coordinateY = (processLineBorders[1] + (processLineBorders[3] - processLineBorders[1]) / 2) - (textExtents.height / 2 + textExtents.yBearing),
                    textExtents = textExtents
                )

                showCenterText(
                    context = context,
                    text = textStartProcess,
                    sizeFont = 10 * coefficientSize,
                    coordinateX = (firstCoordinateX) - (textExtents.width / 2 + textExtents.xBearing),
                    coordinateY = (processLineBorders[3]) + (textExtents.height * 1.25),
                    textExtents = textExtents
                )

                showCenterText(
                    context = context,
                    text = textEndProcess,
                    sizeFont = 10 * coefficientSize,
                    coordinateX = (secondCoordinateX) - (textExtents.width / 2 + textExtents.xBearing),
                    coordinateY = (processLineBorders[3]) + (textExtents.height * 1.25),
                    textExtents = textExtents
                )
            
            context.setFontSize(10 * coefficientSize)

            context.textExtents(textTotalTime, textExtents)
            context.moveTo(0, nextYspecText)
            context.showText(textTotalTime)
            nextYspecText += textExtents.height

            context.textExtents(textAverageWaitTime, textExtents)
            context.moveTo(0, nextYspecText)
            context.showText(textAverageWaitTime)
            nextYspecText += textExtents.height
        else:
            let
                processPIDdraw: int = choiseMode - 1
                resultProcess: ResultProcess = drawingSJFDialog.tableResult.filterIt(it.PID == processPIDdraw)[0]
                textNameProcess: string = "P" & $processPIDdraw
                textStartProcess: string = $(resultProcess.completionTime - (resultProcess.turnAroundTime - resultProcess.waitingTime))
                textEndProcess: string = $(resultProcess.completionTime)
                textTurnAroundTime: string = "Turn around time = " & $(resultProcess.turnAroundTime)
                textWaitingTime: string = "Waiting time = " & $(resultProcess.waitingTime)

            context.rectangle(
                remapRange(25.0, 0.0, 100.0, 0.0, width.float),
                remapRange(25.0, 0.0, 100.0, 0.0, height.float),
                remapRange(50.0, 0.0, 100.0, 0.0, width.float),
                remapRange(50.0, 0.0, 100.0, 0.0, height.float)
            )
            context.stroke()


            showCenterText(
                context = context,
                text = textNameProcess,
                sizeFont = 24 * coefficientSize,
                coordinateX = remapRange(50.0, 0.0, 100.0, 0.0, width.float) - (textExtents.width / 2 + textExtents.xBearing),
                coordinateY = remapRange(50.0, 0.0, 100.0, 0.0, height.float) - (textExtents.height / 2 + textExtents.yBearing),
                textExtents = textExtents
            )

            showCenterText(
                context = context,
                text = textStartProcess,
                sizeFont = 14 * coefficientSize,
                coordinateX = remapRange(25.0, 0.0, 100.0, 0.0, width.float) - (textExtents.width / 2 + textExtents.xBearing),
                coordinateY = remapRange(80.0, 0.0, 100.0, 0.0, height.float) - (textExtents.height / 2 + textExtents.yBearing),
                textExtents = textExtents
            )

            showCenterText(
                context = context,
                text = textEndProcess,
                sizeFont = 14 * coefficientSize,
                coordinateX = remapRange(75.0, 0.0, 100.0, 0.0, width.float) - (textExtents.width / 2 + textExtents.xBearing),
                coordinateY = remapRange(80.0, 0.0, 100.0, 0.0, height.float) - (textExtents.height / 2 + textExtents.yBearing),
                textExtents = textExtents
            )

            context.setFontSize(10 * coefficientSize)

            context.textExtents(textTurnAroundTime, textExtents)
            context.moveTo(0, nextYspecText)
            context.showText(textTurnAroundTime)
            nextYspecText += textExtents.height

            context.textExtents(textWaitingTime, textExtents)
            context.moveTo(0, nextYspecText)
            context.showText(textWaitingTime)
            nextYspecText += textExtents.height

proc initDrawingSJFDialog*[T](result: var T, tableResult: TableResult) =
    assert(result is DrawingSJFDialog)
    
    let
        dialogBox: Box = result.contentArea
        drawingProcesses: DrawingArea = newDrawingArea()
        choosingMode: ComboBoxText = newComboBoxText()

    result.tableResult = tableResult.sorted(proc (a, b: ResultProcess): int = cmp(a.PID, b.PID))
    result.drawingProcesses = drawingProcesses
    result.choosingMode = choosingMode

    choosingMode.appendText("Все")
    for index in 0 ..< len(result.tableResult):
        choosingMode.appendText($result.tableResult[index].PID)
    
    choosingMode.setActive(0)
    choosingMode.connect("changed", changedMode, result)

    drawingProcesses.setDrawFunc(drawProcesses, result)
    drawingProcesses.hexpand = true
    drawingProcesses.vexpand = true

    dialogBox.orientation = Orientation.vertical
    dialogBox.append(drawingProcesses)
    dialogBox.append(choosingMode)

proc initDrawingSJFDialog*[T](result: var T, window: Window, tableResult: TableResult) =
    initDrawingSJFDialog(result, tableResult)
    result.setTransientFor(window)

proc newDrawingSJFDialog*(tableResult: TableResult): DrawingSJFDialog =
    result = newDialog(DrawingSJFDialog)
    initDrawingSJFDialog(result, tableResult)

proc newDrawingSJFDialog*(window: Window, tableResult: TableResult): DrawingSJFDialog =
    result = newDialog(DrawingSJFDialog)
    initDrawingSJFDialog(result, window, tableResult)
