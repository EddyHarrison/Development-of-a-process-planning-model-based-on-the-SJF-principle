import gintro/[gtk4, glib, gobject, gio]
import sequtils

type
    DataEditColomn = tuple
        table: EditableTable
        positionColomn: int
    DataEditElement = tuple
        table: EditableTable
        positionColomn: int
        positionRow: int
    EditableTable* = ref object of Box
        columnView: ColumnView
        rowsList: StringList
        dataTable: seq[seq[string]]

proc changeTableElement(editableLabel: EditableLabel, dataEditElement: DataEditElement) =
    let
        changedElement: string = editableLabel.getText()
        positionRow: int = dataEditElement.positionRow
        positionColomn: int = dataEditElement.positionColomn
    
    dataEditElement.table.dataTable[positionRow][positionColomn] = changedElement

proc setupColomn(factory: SignalListItemFactory, listItem: ListItem) =
    let
        editableLabel: EditableLabel = newEditableLabel("")

    listItem.setChild(editableLabel)

proc bindColomn(factory: SignalListItemFactory, listItem: ListItem, dataEditColomn: DataEditColomn) =
    let
        editableLabel: EditableLabel = listitem.getChild.EditableLabel
        dataEditElement: DataEditElement = (dataEditColomn.table, dataEditColomn.positionColomn, listItem.getPosition)

    editableLabel.connect("changed", changeTableElement, dataEditElement)

proc unbindColomn(factory: SignalListItemFactory, listItem: ListItem) =
    discard

proc teardownColomn(factory: SignalListItemFactory, listItem: ListItem) =
    listItem.setChild(nil)

proc addColomn(editableTable: EditableTable, nameColomn: string) =
    let
        factory: SignalListItemFactory = newSignalListItemFactory()
        column = newColumnViewColumn(nameColomn, factory)
        positionColomn: int = editableTable.columnView.getColumns.getNItems
    
    column.resizable = true
    
    factory.connect("setup", setupColomn)
    factory.connect("bind", bindColomn, (editableTable, positionColomn))
    factory.connect("unbind", unbindColomn)
    factory.connect("teardown", teardownColomn)

    for index in 0 ..< len(editableTable.dataTable):
        editableTable.dataTable[index].add("")

    editableTable.columnView.appendColumn(column)

proc addRow*(editableTable: EditableTable) =
    let
        colomnCount: Natural = editableTable.columnView.getColumns.getNItems.Natural

    editableTable.dataTable.add(sequtils.repeat("", colomnCount))
    editableTable.rowsList.append("")

proc removeRow*(editableTable: EditableTable, positionRow: int) =
    editableTable.dataTable.delete(positionRow)
    editableTable.rowsList.remove(positionRow)

proc removeSelectebleRow*(editableTable: EditableTable) =
    let
        selectedColumn: Bitset = editableTable.columnView.getModel.getSelection
    
    for index in 0 ..< selectedColumn.getSize.int:
        editableTable.removeRow(selectedColumn.getNth(index))

proc getTable*(editableTable: EditableTable): seq[seq[string]] =
    return editableTable.dataTable

proc getElementTable*(editableTable: EditableTable, positionRow, positionColumn: int): string = 
    return editableTable.dataTable[positionRow][positionColumn]

proc initEditableTable*[T](result: var T, namesColumn: openArray[string]) =
    assert(result is EditableTable)

    let
        rowsList: StringList = newStringList()
        listModel: ListModel = listModel(rowsList)
        multiSelection: MultiSelection = newMultiSelection(listModel)

    result.columnView = newColumnView(multiSelection)
    result.append(result.columnView)

    result.rowsList = rowsList
    result.dataTable = @[]

    for index in 0 ..< len(namesColumn):
        result.addColomn(namesColumn[index])

proc newEditableTable*(namesColumn: openArray[string]): EditableTable =
    result = newBox(EditableTable, Orientation.vertical)
    initEditableTable(result, namesColumn)
