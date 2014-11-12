from PyQt4.QtGui import *
from PyQt4.QtCore import *
from ccsPost import *
from ccsPre import *
import sys, os

class MainConfig(QWidget):
    def __init__(self, parent=None):
        super(MainConfig, self).__init__(parent)


        Lab=QLabel("Configure File  ")
        Ety=QLineEdit()
        LoadBtn=QPushButton("Load")
        SaveBtn=QPushButton("Save")
        DefaultBtn=QPushButton("Default")
        CheckBtn=QPushButton("Check")

        HBox=QHBoxLayout()
        HBox.setMargin(0)
        HBox.setSpacing(0)
        HBox.addWidget(Lab)
        HBox.addWidget(Ety)
        HBox.addWidget(LoadBtn)
        HBox.addWidget(SaveBtn)
        HBox.addWidget(DefaultBtn)

        Area=QScrollArea()
        Area.setFrameStyle(QFrame.Panel|QFrame.Sunken)
        Area.setWidgetResizable(True)

        mainLayout=QVBoxLayout(self)
        mainLayout.setMargin(8)
        mainLayout.setSpacing(5)
        mainLayout.addLayout(HBox)
        mainLayout.addWidget(Area)

        self.connect(SaveBtn, SIGNAL("clicked()"),
                self.saveConfig)
        self.connect(LoadBtn, SIGNAL("clicked()"),
                self.loadConfig)
        self.connect(DefaultBtn, SIGNAL("clicked()"),
                self.defaultConfig)

        self.Ety=Ety
        self.Area=Area

    def setWidget(self, para):
        self.Area.setWidget(para)
        self.para=para

    def saveConfig(self):
        File=QFileDialog.getSaveFileName(self,
                self.tr("Save Configure File"),
                QDir.currentPath())
        if File.isEmpty():
            return

        self.Ety.setText(File)
        fp=open(File, "w")
        self.para.save(fp)
        fp.close()

    def loadConfig(self):
        File=QFileDialog.getOpenFileName(self,
                self.tr("Load Configure File"),
                QDir.currentPath())
        if File.isEmpty():
            return

        self.Ety.setText(File)
        fp=open(File, "r")
        self.para.load(fp)
        fp.close()

    def defaultConfig(self):
        self.para.default()

class MainPost(MainConfig):
    def __init__(self, parent=None):
        super(MainPost, self).__init__(parent)
        
        para=PostConfig()
        self.setWidget(para)
        self.para=para

class MainPre(MainConfig):
    def __init__(self, parent=None):
        super(MainPre, self).__init__(parent)

        para=PreConfig()
        self.setWidget(para)
        self.para=para

if __name__=='__main__':
    app=QApplication(sys.argv)
    main=MainPost()
    main.show()
    app.exec_()
