from PyQt4.QtGui import *
from PyQt4.QtCore import *
import sys, os

class Group(QGroupBox):
    def __init__(self,
            parent=None,
            direction=QBoxLayout.LeftToRight):
        super(Group, self).__init__(parent)
        Box=QBoxLayout(direction)
        Box.setMargin(5)
        Box.setSpacing(2)

        self.setLayout(Box)
        
        self.Box=Box

    def addChildWidget(self, widget):
        self.Box.addWidget(widget)

    def addChildLayout(self, layout):
        self.Box.addLayout(layout)

class FrameLayout(QFrame):
    def __init__(self, 
            parent=None,
            direction=QBoxLayout.LeftToRight):
        super(FrameLayout, self).__init__(parent)

        Box=QBoxLayout(direction)
        Box.setMargin(5)
        Box.setSpacing(2)
        self.setLayout(Box)

        self.Box=Box

    def addChildWidget(self, widget):
        self.Box.addWidget(widget)
    
    def addChildLayout(self, layout):
        self.Box.addLayout(layout)

def checkValue(value, widget, flag="f"):
    if widget.signalsBlocked():
        return
    widget.blockSignals(True)

    Num=widget.displayText()

    if Num.isEmpty():
        widget.blockSignals(False)
        return QString()

    if flag=="s":
        widget.blockSignals(False)
        return Num
    try:
        if flag=="f":
            Num=float(Num)
        elif flag=="i":
            Num=int(Num)
    except:
        QMessageBox.critical(widget, "Input Error",
                widget.tr("Please input a right digit"))
        if value is None:
            widget.setText(QString())
        else:
            widget.setText(QString(str(value)))
        widget.blockSignals(False)
        return

    if Num < 0:
        QMessageBox.critical(widget, "Input Error",
                widget.tr("High cut-off must >= 0!"))
        if value is None:
            widget.setText(QString())
        else:
            widget.setText(QString(str(value)))
        widget.blockSignals(False)
        return

    widget.blockSignals(False)
    return Num

class BandBox(QFrame):
    def __init__(self, parent=None):
        super(BandBox, self).__init__(parent)

        BandLab=QLabel("Band")
        LowEty=QLineEdit()
        LowEty.setToolTip(
                "Set low cut-off frequency "+
                "of high-pass filter")
        Tilde=QLabel("-")
        HighEty=QLineEdit()
        HighEty.setToolTip(
                "Set high cut-off frequency "+
                "of low-pass filter")

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)
        mainLayout.addWidget(BandLab)
        mainLayout.addWidget(LowEty)
        mainLayout.addWidget(Tilde)
        mainLayout.addWidget(HighEty)

        self.connect(LowEty, SIGNAL("editingFinished()"),
                self.editLow)
        self.connect(HighEty, SIGNAL("editingFinished()"),
                self.editHigh)

        self.LowEty=LowEty
        self.HighEty=HighEty
        self.low=None
        self.high=None

    def editLow(self):
        low=checkValue(self.low, self.LowEty)
        if not low is None:
            Str=QString(str(low))
            if Str.isEmpty():
                self.low=None
            else:
                self.low=low
            self.emit(SIGNAL("updateLow(QString)"),
                    Str)

    def editHigh(self):
        high=checkValue(self.high, self.HighEty)
        if not high is None:
            Str=QString(str(high))
            if Str.isEmpty():
                self.high=None
            else:
                self.high=high
            self.emit(SIGNAL("updateHigh(QString)"),
                    Str)

    def getLow(self):
        return self.low

    def getHigh(self):
        return self.high

    def setLow(self, low):
        self.low=low
        if low is None:
            self.LowEty.setText(QString())
        else:
            self.LowEty.setText(QString(str(low)))
        self.LowEty.emit(SIGNAL("editingFinished()"))

    def setHigh(self, high):
        self.high=high
        if high is None:
            self.HighEty.setText(QString())
        else:
            self.HighEty.setText(QString(str(high)))
        self.HighEty.emit(SIGNAL("editingFinished()"))

    def setDisabled(self, state):
        if state:
            self.LowEty.setText(QString())
            self.HighEty.setText(QString())
            self.low=None
            self.high=None
        self.LowEty.setDisabled(state)
        self.HighEty.setDisabled(state)


class ValueBox(QFrame):
    def __init__(self, parent=None):
        super(ValueBox, self).__init__(parent)

        Lab=QLabel("p value")
        Ety=QLineEdit()
        Ety.setToolTip("Set p value")

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)
        mainLayout.addWidget(Lab)
        mainLayout.addWidget(Ety)

        self.connect(Ety, SIGNAL("editingFinished()"),
                self.editValue)

        self.Lab=Lab
        self.Ety=Ety
        self.value=None

    def editValue(self):
        value=checkValue(self.value, self.Ety)
        if not value is None:
            Str=QString(str(value))
            if Str.isEmpty():
                self.value=None
            else:
                self.value=value
            self.emit(SIGNAL("update(QString)"), Str)

    def getValue(self):
        return self.value

    def setValue(self, value):
        self.value=value
        if value is None:
            self.Ety.setText(QString())
        else:
            self.Ety.setText(QString(str(value)))
        self.Ety.emit(SIGNAL("editingFinished()"))

    def setDisabled(self, state):
        if state:
            self.Ety.setText(QString())
        self.value=None
        self.Ety.setDisabled(state)
        self.Ety.emit(SIGNAL("editingFinished()"))

    def changeToOther(self, title, tooltip):
        self.Lab.setText(title)
        self.Ety.setToolTip(tooltip)

    def setFixedWidth(self, width):
        self.Lab.setFixedWidth(width)

class DCBox(QWidget):
    def __init__(self, parent=None):
        super(DCBox, self).__init__(parent)
        Btn=QCheckBox("DC")
        Btn.setToolTip(
                """
Degree Centrality (DC):
DC is the number of edges connecting to a node. For a weighted
graph, it is defined as the sum of weights from edges connecting
to a node. The node and edge here is defined as the voxel and
the functional connection between each voxel.
For weight DC, the edge value is Pearson's correlation
coefficient of resting state time series. For unweighted DC, the
edge value is setting to 1 if its Pearson's correlation is
significant for threshold-p.
                """
                )

        valueBox=ValueBox()
        valueBox.setDisabled(True)
        valueBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Sunken)

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)
        mainLayout.addWidget(Btn)
        mainLayout.addWidget(valueBox)

        self.connect(Btn, SIGNAL("stateChanged(int)"),
                self.updateState)
        self.connect(valueBox, SIGNAL("update(QString)"),
                self, SIGNAL("updateP(QString)"))

        self.Btn=Btn
        self.valueBox=valueBox

    def getState(self):
        state=self.Btn.isChecked()
        return state

    def setState(self, state):
        self.Btn.setChecked(state)

    def updateState(self, state):
        state=bool(state)
        self.emit(SIGNAL("updateState(bool)"), state)
        flag=not state
        self.valueBox.setDisabled(flag)

    def getValue(self):
        value=self.valueBox.getValue()
        return value

    def setValue(self, value):
        self.valueBox.setValue(value)

    def changeToOther(self, title, tooltip):
        self.Btn.setText(title)
        self.Btn.setToolTip(tooltip)

class FileBoxCombo(QFrame):
    def __init__(self, parent=None):
        super(FileBoxCombo, self).__init__(parent)

        Lab=QCheckBox("File Combo")
        Combo=QComboBox()
        Combo.setDisabled(True)
        Btn=QPushButton("...")
        Btn.setDisabled(True)

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)
        mainLayout.addWidget(Lab)

        HBox=QHBoxLayout()
        HBox.setMargin(5)
        HBox.setSpacing(2)
        HBox.addWidget(Combo)
        HBox.addWidget(Btn)
        HBox.setStretchFactor(Combo, 1)

        mainLayout.addLayout(HBox)
        
        self.connect(Lab, SIGNAL("stateChanged(int)"),
                self.updateState)
        self.connect(Combo,
                SIGNAL("currentIndexChanged(int)"),
                self.updateComboTooltip)
        self.connect(Btn, SIGNAL("clicked()"),
                self.openFiles)

        self.Lab=Lab
        self.Combo=Combo
        self.Btn=Btn

        self.Files=None

    def openFiles(self):
        Files=self.Files
        if Files is None:
            Dir=QDir.currentPath()
        else:
            Info=QFileInfo(Files[0])
            Dir=Info.absoluteFilePath()

        Files=QFileDialog.getOpenFileNames(self,
                self.tr("Select Nifti Images"),
                Dir,
                self.tr("Template { *.nii, *.nii.gz } "+
                    "(*.nii *.nii.gz);;"+
                    "All Files { *.* } (*.* *)")
                )

        if Files.isEmpty():
            return
       
        self.Combo.clear()
        #for File in Files:
        #    self.Combo.addItem(File)
        self.Combo.addItems(Files)

        self.emit(SIGNAL("updateList(QStringList)"), 
                Files)
        self.Files=Files

    def getFiles(self):
        Files=self.Files
        return Files

    def setFiles(self, Files):
        if Files is None:
            Str=QStringList()
        else:
            Str=Files
        self.Combo.clear()
        self.Combo.addItems(Str)
        self.emit(SIGNAL("updateList(QStringList)"),
                Str)
        self.Files=Files

    def setLabText(self, text):
        self.Lab.setText(text)

    def setLabToolTip(self, tooltip):
        self.Lab.setToolTip(tooltip)

    def setLabFixedWidth(self, width):
        self.Lab.setFixedWidth(width)

    def updateComboTooltip(self, index):
        item=self.Combo.itemText(index)
        self.Combo.setToolTip(item)

    def updateState(self, state):
        state=bool(state)
        nonstate=not state
        self.Combo.clear()
        self.Combo.setDisabled(nonstate)
        self.Btn.setDisabled(nonstate)

        self.Files=None
        self.emit(SIGNAL("updateState(bool)"), state)
        self.emit(SIGNAL("updateList(QStirngList)"), 
                QStringList())

    def getState(self):
        state=self.Lab.isChecked()
        return state

    def setState(self, state):
        self.Lab.setChecked(state)

    def setDisabled(self, nonstate):
        self.Lab.setDisabled(nonstate)
        self.setState(False)

class FileBox(QFrame):
    def __init__(self, parent=None):
        super(FileBox, self).__init__(parent)

        Ety=QLineEdit()
        Btn=QPushButton("...")

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(0)
        mainLayout.setSpacing(0)
        mainLayout.addWidget(Ety)
        mainLayout.addWidget(Btn)

        self.connect(Ety, SIGNAL("editingFinished()"),
                self.editFile)
        self.connect(Btn, SIGNAL("clicked()"),
                self.openFile) 

        self.Ety=Ety
        self.Btn=Btn
        self.File=None

    def editFile(self):
        if self.Ety.signalsBlocked():
            return
        self.Ety.blockSignals(True)

        File=self.Ety.displayText()
        Info=QFileInfo(File)
        if File.isEmpty():
            self.File=None
            self.Ety.blockSignals(False)
            self.emit(SIGNAL("update(QString)"), File)
            return

        if Info.exists():
            self.File=File
            self.Ety.blockSignals(False)
            self.emit(SIGNAL("update(QString)"), File)
            return

        QMessageBox.critical(self.Ety, "File Error",
                self.tr("This file do not exist!"))
        File=self.File
        if File is None:
            self.Ety.setText(QString())
        else:
            self.Ety.setText(File)
        self.Ety.blockSignals(False)

    def openFile(self):
        File=self.File
        if File is None:
            Dir=QDir.currentPath()
        else:
            Info=QFileInfo(File)
            Dir=Info.absoluteFilePath()

        File=QFileDialog.getOpenFileName(self,
                self.tr("Select Nifti Image"),
                Dir,
                self.tr("Template { *.nii, *.nii.gz } "+
                    "(*.nii *.nii.gz);;"+
                    "All Files { *.* } (*.* *)")
                )
        if File.isEmpty():
            return

        self.File=File
        self.Ety.setText(File)
        self.Ety.emit(SIGNAL("editingFinished()"))

    def setDisabled(self, state):
        if state:
            self.Ety.setText(QString())
        self.File=None
        self.Ety.emit(SIGNAL("editingFinished()"))

        self.Ety.setDisabled(state)
        self.Btn.setDisabled(state)

    def getFile(self):
        return self.File

    def setFile(self, File):
        if File is None:
            self.Ety.setText(QString())
        else:
            self.Ety.setText(File)
        self.File=File
        self.Ety.emit(SIGNAL("editingFinished()"))

    def setToolTip(self, tooltip):
        self.Btn.setToolTip(tooltip)

class DirBox(FileBox):
    def __init__(self, parent=None):
        super(DirBox, self).__init__(parent)

    def editFile(self):
        if self.Ety.signalsBlocked():
            return
        self.Ety.blockSignals(True)

        Dir=self.Ety.displayText()
        Info=QDir(Dir)

        if Dir.isEmpty():
            self.File=None
            self.Ety.blockSignals(False)
            self.emit(SIGNAL("update(QString)"), Dir)
            return

        if Info.exists():
            self.File=Dir
            self.emit(SIGNAL("update(QString)"), Dir)
            self.Ety.blockSignals(False)
            return

        QMessageBox.critical(self.Ety, "Directory Error",
                self.Ety.tr("This directory do no exist!"))
        Dir=self.File
        if self.File is None:
            self.Ety.setText(QString())
        else:
            self.Ety.setText(Dir)
        self.Ety.blockSignals(False)

    def openFile(self):
        Dir=self.File
        if Dir is None:
            Dir=QDir.currentPath()

        Dir=QFileDialog.getExistingDirectory(self,
                "Set Directory",
                Dir,
                QFileDialog.ShowDirsOnly|QFileDialog.DontResolveSymlinks)

        if Dir.isEmpty():
            return

        self.Ety.setText(Dir)
        self.File=Dir
        self.emit(SIGNAL("update(QString)"), Dir)

class FCBox(QFrame):
    def __init__(self, parent=None):
        super(FCBox, self).__init__(parent)

        Btn=QCheckBox("FC")
        Btn.setFixedWidth(80)
        Btn.setToolTip(
            """
Voxel-wise Functional Connectivity (FC):
Please set a seed mask in MNI152 space. The resolution of the seed
mask should be as the same as the resolution of function image.
            """
            )
        fileBox=FileBox()
        fileBox.setDisabled(True)
        fileBox.setToolTip("Set FC Seed Mask")

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)
        mainLayout.addWidget(Btn)
        mainLayout.addWidget(fileBox)

        self.connect(Btn, SIGNAL("stateChanged(int)"),
                self.updateState)
        self.connect(fileBox, 
                SIGNAL("update(QString)"),
                self,
                SIGNAL("updateFile(QString)"))

        self.Btn=Btn
        self.fileBox=fileBox

    def getState(self):
        state=self.Btn.isChecked()
        return state

    def setState(self, state):
        self.Btn.setChecked(state)

    def updateState(self, state):
        state=bool(state)
        self.emit(SIGNAL("updateState(bool)"), state)
        flag=not state
        self.fileBox.setDisabled(flag)

    def getFile(self):
        File=self.fileBox.getFile()
        return File

    def setFile(self, File):
        self.fileBox.setFile(File)

    def changeToOther(self, 
            title, tooltipCheck, tooltipPush):
        self.Btn.setText(title)
        self.Btn.setToolTip(tooltipCheck)
        self.fileBox.setToolTip(tooltipPush)
    
    def setFileWidget(self, fileBox):
        self.fileBox=fileBox
    
    def setFixedWidth(self, width):
        self.Btn.setFixedWidth(width)

class CheckBox(QFrame):
    def __init__(self, parent=None):
        super(CheckBox, self).__init__(parent)

        Btn=QCheckBox("ReHo")
        Btn.setToolTip(
                """
Regional Homogeneity (ReHo):
ReHo is an index to measure the locally functional homogeneity
of a region.
It is calculated by Kendall's coefficient of concordance (KCC)
of resting state time series between each voxel and its 26
neighbors.
                """)

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)
        mainLayout.addWidget(Btn)

        self.connect(Btn, SIGNAL("stateChanged(int)"),
                self.updateState)

        self.Btn=Btn

    def updateState(self, state):
        state=bool(state)
        self.emit(SIGNAL("update(bool)"), state)
        self.emit(SIGNAL("updateState(bool)"), state)

    def getState(self):
        state=self.Btn.isChecked()
        return state

    def setState(self, state):
        self.Btn.setChecked(state)        

    def setLabText(self, text):
        self.Btn.setText(text)

    def setLabToolTip(self, tooltip):
        self.Btn.setToolTip(tooltip)

    def changeToOther(self, title, tooltip):
        self.Btn.setText(title)
        self.Btn.setToolTip(tooltip)

    def setDisabled(self, nonstate):
        self.Btn.setDisabled(nonstate)
        self.setState(False)

class ImageView(QGraphicsView):
    def __init__(self, parent=None):
        super(ImageView, self).__init__(parent)

        scene=QGraphicsScene(self)

        image=QPixmap()
        pixmap=QGraphicsPixmapItem(None, scene)
        pixmap.setPixmap(image)

        self.setScene(scene)
        self.setDragMode(QGraphicsView.ScrollHandDrag)

        self.scene=scene
        self.pixmap=pixmap

    def wheelEvent(self, event):
        factor=1.05
        if event.delta()<0:
            factor=1.0/factor
        self.scale(factor, factor)

    def setPixmap(self, fileN):
        if fileN is None:
            image=QPixmap()
        else:
            image=QPixmap(fileN)
        self.pixmap.setPixmap(image)

if __name__=='__main__':
    app=QApplication(sys.argv)
    main=FileBoxCombo()
    main.setLabText("FC")
    main.show()
    app.exec_()
