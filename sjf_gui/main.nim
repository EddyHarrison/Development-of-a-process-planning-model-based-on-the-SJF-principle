import gintro/[gtk4, gobject, gio]
import drawingsjfdialog
import editabletable
import SJF

type
    ArgsDrawDialog = tuple
        window: Window
        table: EditableTable

proc clickedAddRow(button: Button, editableTable: EditableTable) =
    editableTable.addRow()

proc clickedRemoveRow(button: Button, editableTable: EditableTable) =
    editableTable.removeSelectebleRow()

proc showDialog(button: Button, args: ArgsDrawDialog) =
    var
        rawTableProcesses: seq[seq[string]] = args.table.getTable()

    for index in 0 ..< len(rawTableProcesses):
        rawTableProcesses[index] = $index & rawTableProcesses[index]
    
    let
        tableProcesses: TableProcesses = rawTableProcesses.parseTableProcesses()
        tableResult: TableResult = proscessingSJF(tableProcesses)
        drawingSJFDialog: DrawingSJFDialog = newDrawingSJFDialog(args.window, tableResult)
    
    drawingSJFDialog.setDefaultSize(320, 240)    
    drawingSJFDialog.show()

proc initApplication(app: gtk4.Application) =
    let
        window: ApplicationWindow = newApplicationWindow(app)
        mainBox: Box = newBox(Orientation.vertical)
        buttonsBox: Box = newBox(Orientation.horizontal)
        editableTable: EditableTable = newEditableTable(["arrival time", "burst time"])
        buttonAddRow: Button = newButton("Add row")
        buttonRemoveRow: Button = newButton("Remove row")
        buttonDrawProcesses: Button = newButton("Draw processes")

    editableTable.hexpand = true
    editableTable.vexpand = true

    buttonAddRow.connect("clicked", clickedAddRow, editableTable)
    
    buttonRemoveRow.connect("clicked", clickedRemoveRow, editableTable)
    
    buttonDrawProcesses.connect("clicked", showDialog, (window.Window, editableTable))

    buttonsBox.spacing = 3
    buttonsBox.homogeneous = true    
    buttonsBox.append(buttonAddRow)
    buttonsBox.append(buttonRemoveRow)
    buttonsBox.append(buttonDrawProcesses)

    mainBox.append(editableTable)
    mainBox.append(buttonsBox)

    window.title = "SJF"
    window.setChild(mainBox)
    window.setDefaultSize(480, 320)
    window.show()

proc main =
    let app = newApplication("ru.cherry228")
    app.connect("activate", initApplication)
    discard app.run()

when isMainModule:
    main()
