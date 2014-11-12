from PyQt4.QtGui import *
from PyQt4.QtCore import *
from ccsBase import *
from ccsConfig import *
from ccsSkull import *
from ccsProcess import *
import sys, os

class main(QWidget):
    def __init__(self, parent=None):
        super(main, self).__init__(parent)

        self.setWindowTitle(
                "Connectome Computation System")
        self.setGeometry(200, 100, 683, 540)

        ad=ImageView()
        CCSDIR=os.getenv("CCSDIR")
        Logo=os.path.join(CCSDIR, "gui", "CCSlogo.png")
        ad.setPixmap(Logo)
        analysisBox=AnaDirBox()
        pre=MainPre()
        post=MainPost()
        skull=MainSkull()

        anat=MainAnat()
        func=MainFunc()
        postproc=PostProcess()

        tabwidget=QTabWidget()
        tabwidget.setUsesScrollButtons(True)
        tabwidget.addTab(ad,    "Main")
        tabwidget.addTab(pre,   "Pre-Configure")
        tabwidget.addTab(skull, "Skull Strip")
        tabwidget.addTab(anat,  "Anat Process")
        tabwidget.addTab(func,  "Func Process")
        tabwidget.addTab(post,  "Post-Configure")
        tabwidget.addTab(postproc,  "Post Process")
    
        mainLayout=QVBoxLayout(self)
        mainLayout.addWidget(analysisBox)
        mainLayout.addWidget(tabwidget)

        #Skull Strip SLOT
        self.connect(analysisBox,
                SIGNAL("updatePath(QString)"),
                skull.terminal,
                SLOT("setAnalysisDir(QString)"))
        self.connect(analysisBox,
                SIGNAL("updateList(QString)"),
                skull.terminal,
                SLOT("setSubjectList(QString)"))
        self.connect(pre.para,
                SIGNAL("updateAnatDir(QString)"),
                skull.terminal,
                SLOT("setAnatDir(QString)"))
        self.connect(pre.para,
                SIGNAL("updateAnatFile(QString)"),
                skull.terminal,
                SLOT("setAnatFile(QString)"))
        self.connect(pre.para,
                SIGNAL("updateScansNum(QString)"),
                skull.terminal,
                SLOT("setScansNum(QString)"))
        self.connect(pre.para,
                SIGNAL("updateGcut(bool)"),
                skull.terminal,
                SLOT("setGcut(bool)"))
        self.connect(pre.para,
                SIGNAL("updateDenoised(bool)"),
                skull.terminal,
                SLOT("setDenoised(bool)"))

        self.connect(pre.para, 
                SIGNAL("updateAnatDir(QString)"),
                skull.check,
                SLOT("setAnatDir(QString)"))
        self.connect(analysisBox, 
                SIGNAL("updatePath(QString)"),
                skull.check,
                SLOT("setAnalysisDir(QString)"))

        #Anat Process SLOT
        self.connect(analysisBox,
                SIGNAL("updatePath(QString)"),
                anat.terminal,
                SLOT("setAnalysisDir(QString)"))
        self.connect(analysisBox,
                SIGNAL("updateList(QString)"),
                anat.terminal,
                SLOT("setSubjectList(QString)"))
        self.connect(pre.para,
                SIGNAL("updateAnatDir(QString)"),
                anat.terminal,
                SLOT("setAnatDir(QString)"))
        self.connect(pre.para,
                SIGNAL("updateAnatFile(QString)"),
                anat.terminal,
                SLOT("setAnatFile(QString)"))
        self.connect(pre.para,
                SIGNAL("updateGPU(bool)"),
                anat.terminal,
                SLOT("setGPU(bool)"))
        self.connect(pre.para,
                SIGNAL("updateHead(QString)"),
                anat.terminal,
                SLOT("setHead(QString)"))
        self.connect(pre.para,
                SIGNAL("updateBrain(QString)"),
                anat.terminal,
                SLOT("setBrain(QString)"))
        self.connect(pre.para,
                SIGNAL("updateIsRefine(bool)"),
                anat.terminal,
                SLOT("setIsRefine(bool)"))
        self.connect(pre.para,
                SIGNAL("updateRefine(QString)"),
                anat.terminal,
                SLOT("setRefine(QString)"))

        self.connect(pre.para, 
                SIGNAL("updateAnatDir(QString)"),
                anat.surf_check,
                SLOT("setAnatDir(QString)"))
        self.connect(analysisBox, 
                SIGNAL("updatePath(QString)"),
                anat.surf_check,
                SLOT("setAnalysisDir(QString)"))
        self.connect(pre.para, 
                SIGNAL("updateAnatDir(QString)"),
                anat.surf_check.terminal,
                SLOT("setAnatDir(QString)"))
        self.connect(analysisBox,
                SIGNAL("updateList(QString)"),
                anat.surf_check.terminal,
                SLOT("setSubjectList(QString)"))
        self.connect(analysisBox, 
                SIGNAL("updatePath(QString)"),
                anat.surf_check.terminal,
                SLOT("setAnalysisDir(QString)"))

        self.connect(pre.para, 
                SIGNAL("updateAnatDir(QString)"),
                anat.reg_check,
                SLOT("setAnatDir(QString)"))
        self.connect(analysisBox, 
                SIGNAL("updatePath(QString)"),
                anat.reg_check,
                SLOT("setAnalysisDir(QString)"))
        self.connect(pre.para, 
                SIGNAL("updateAnatDir(QString)"),
                anat.reg_check.terminal,
                SLOT("setAnatDir(QString)"))
        self.connect(analysisBox,
                SIGNAL("updateList(QString)"),
                anat.reg_check.terminal,
                SLOT("setSubjectList(QString)"))
        self.connect(analysisBox, 
                SIGNAL("updatePath(QString)"),
                anat.reg_check.terminal,
                SLOT("setAnalysisDir(QString)"))
        self.connect(pre.para,
                SIGNAL("updateBrain(QString)"),
                anat.reg_check.terminal,
                SLOT("setBrain(QString)"))
        self.connect(pre.para,
                SIGNAL("updateIsRefine(bool)"),
                anat.reg_check.terminal,
                SLOT("setIsRefine(bool)"))

        #Func Process SLOT
        self.connect(analysisBox,
                SIGNAL("updatePath(QString)"),
                func.terminal,
                SLOT("setAnalysisDir(QString)"))
        self.connect(analysisBox,
                SIGNAL("updateList(QString)"),
                func.terminal,
                SLOT("setSubjectList(QString)"))
        self.connect(pre.para,
                SIGNAL("updateAnatDir(QString)"),
                func.terminal,
                SLOT("setAnatDir(QString)"))
        self.connect(pre.para,
                SIGNAL("updateFuncDir(QString)"),
                func.terminal,
                SLOT("setFuncDir(QString)"))
        self.connect(pre.para,
                SIGNAL("updateFuncFile(QString)"),
                func.terminal,
                SLOT("setFuncFile(QString)"))
        self.connect(pre.para,
                SIGNAL("updateTR(QString)"),
                func.terminal,
                SLOT("setTR(QString)"))
        self.connect(pre.para,
                SIGNAL("updateDropNum(QString)"),
                func.terminal,
                SLOT("setDropNum(QString)"))
        self.connect(pre.para,
                SIGNAL("updateTPattern(QString)"),
                func.terminal,
                SLOT("setTPattern(QString)"))
        self.connect(pre.para,
                SIGNAL("updateBandLow(QString)"),
                func.terminal,
                SLOT("setBandLow(QString)"))
        self.connect(pre.para,
                SIGNAL("updateBandHigh(QString)"),
                func.terminal,
                SLOT("setBandHigh(QString)"))
        self.connect(pre.para,
                SIGNAL("updateFunc(QString)"),
                func.terminal,
                SLOT("setFunc(QString)"))
        self.connect(pre.para,
                SIGNAL("updateSurface(QString)"),
                func.terminal,
                SLOT("setSurface(QString)"))
        self.connect(pre.para,
                SIGNAL("updateIsRefine(bool)"),
                func.terminal,
                SLOT("setIsRefine(bool)"))
        self.connect(pre.para,
                SIGNAL("updateRefine(QString)"),
                func.terminal,
                SLOT("setRefine(QString)"))

        self.connect(pre.para, 
                SIGNAL("updateFuncDir(QString)"),
                func.bbr_check,
                SLOT("setAnatDir(QString)"))
        self.connect(analysisBox, 
                SIGNAL("updatePath(QString)"),
                func.bbr_check,
                SLOT("setAnalysisDir(QString)"))
        self.connect(pre.para, 
                SIGNAL("updateFuncDir(QString)"),
                func.bbr_check.terminal,
                SLOT("setAnatDir(QString)"))
        self.connect(analysisBox,
                SIGNAL("updateList(QString)"),
                func.bbr_check.terminal,
                SLOT("setSubjectList(QString)"))
        self.connect(analysisBox, 
                SIGNAL("updatePath(QString)"),
                func.bbr_check.terminal,
                SLOT("setAnalysisDir(QString)"))

        self.connect(pre.para, 
                SIGNAL("updateFuncDir(QString)"),
                func.reg_check,
                SLOT("setAnatDir(QString)"))
        self.connect(analysisBox, 
                SIGNAL("updatePath(QString)"),
                func.reg_check,
                SLOT("setAnalysisDir(QString)"))
        self.connect(pre.para, 
                SIGNAL("updateFuncDir(QString)"),
                func.reg_check.terminal,
                SLOT("setAnatDir(QString)"))
        self.connect(analysisBox,
                SIGNAL("updateList(QString)"),
                func.reg_check.terminal,
                SLOT("setSubjectList(QString)"))
        self.connect(analysisBox, 
                SIGNAL("updatePath(QString)"),
                func.reg_check.terminal,
                SLOT("setAnalysisDir(QString)"))
        self.connect(pre.para,
                SIGNAL("updateFunc(QString)"),
                func.reg_check.terminal,
                SLOT("setFunc(QString)"))

        #Post SLOT
        self.connect(analysisBox,
                SIGNAL("updatePath(QString)"),
                postproc,
                SLOT("setAnalysisDir(QString)"))
        self.connect(analysisBox,
                SIGNAL("updateList(QString)"),
                postproc,
                SLOT("setSubjectList(QString)"))
        self.connect(pre.para,
                SIGNAL("updateAnatDir(QString)"),
                postproc,
                SLOT("setAnatDir(QString)"))
        self.connect(pre.para,
                SIGNAL("updateFuncDir(QString)"),
                postproc,
                SLOT("setFuncDir(QString)"))
        self.connect(pre.para,
                SIGNAL("updateFuncFile(QString)"),
                postproc,
                SLOT("setFuncFile(QString)"))
        self.connect(pre.para,
                SIGNAL("updateIsRefine(bool)"),
                postproc,
                SLOT("setIsRefine(bool)"))
        self.connect(pre.para,
                SIGNAL("updateRefine(QString)"),
                postproc,
                SLOT("setRefine(QString)"))
        self.connect(pre.para,
                SIGNAL("updateFunc(QString)"),
                postproc,
                SLOT("setFunc(QString)"))
        self.connect(pre.para,
                SIGNAL("updateSurface(QString)"),
                postproc,
                SLOT("setSurface(QString)"))
        self.connect(pre.para,
                SIGNAL("updateTR(QString)"),
                postproc,
                SLOT("setTR(QString)"))

        #Volume
        self.connect(post.para,
                SIGNAL("updateVolState(bool)"),
                postproc,
                SLOT("setVolState(bool)"))
        self.connect(post.para,
                SIGNAL("updateVolALFFState(bool)"),
                postproc,
                SLOT("setVolALFFState(bool)"))
        self.connect(post.para,
                SIGNAL("updateVolReHoState(bool)"),
                postproc,
                SLOT("setVolReHoState(bool)"))
        self.connect(post.para,
                SIGNAL("updateVolVMHCState(bool)"),
                postproc,
                SLOT("setVolVMHCState(bool)"))
        self.connect(post.para,
                SIGNAL("updateVolDCState(bool)"),
                postproc,
                SLOT("setVolDCState(bool)"))
        self.connect(post.para,
                SIGNAL("updateVolECState(bool)"),
                postproc,
                SLOT("setVolECState(bool)"))
        self.connect(post.para,
                SIGNAL("updateVolBCState(bool)"),
                postproc,
                SLOT("setVolBCState(bool)"))
        self.connect(post.para,
                SIGNAL("updateVolPCState(bool)"),
                postproc,
                SLOT("setVolPCState(bool)"))
        self.connect(post.para,
                SIGNAL("updateVolVNCMPValue(QString)"),
                postproc,
                SLOT("setVolVNCMPValue(QString)"))
        self.connect(post.para,
                SIGNAL("updateVolFCState(bool)"),
                postproc,
                SLOT("setVolFCState(bool)"))
        self.connect(post.para,
                SIGNAL("updateVolFCListFile(QString)"),
                postproc,
                SLOT("setVolFCListFile(QString)"))

        #Surface
        self.connect(post.para,
                SIGNAL("updateSurState(bool)"),
                postproc,
                SLOT("setSurState(bool)"))
        self.connect(post.para,
                SIGNAL("updateSurALFFState(bool)"),
                postproc,
                SLOT("setSurALFFState(bool)"))
        self.connect(post.para,
                SIGNAL("updateSurReHoState(bool)"),
                postproc,
                SLOT("setSurReHoState(bool)"))
        self.connect(post.para,
                SIGNAL("updateSurVMHCState(bool)"),
                postproc,
                SLOT("setSurVMHCState(bool)"))
        self.connect(post.para,
                SIGNAL("updateSurDCState(bool)"),
                postproc,
                SLOT("setSurDCState(bool)"))
        self.connect(post.para,
                SIGNAL("updateSurECState(bool)"),
                postproc,
                SLOT("setSurECState(bool)"))
        self.connect(post.para,
                SIGNAL("updateSurBCState(bool)"),
                postproc,
                SLOT("setSurBCState(bool)"))
        self.connect(post.para,
                SIGNAL("updateSurPCState(bool)"),
                postproc,
                SLOT("setSurPCState(bool)"))
        self.connect(post.para,
                SIGNAL("updateSurVNCMPValue(QString)"),
                postproc,
                SLOT("setSurVNCMPValue(QString)"))
        self.connect(post.para,
                SIGNAL("updateSurFCState(bool)"),
                postproc,
                SLOT("setSurFCState(bool)"))
        self.connect(post.para,
                SIGNAL("updateSurFCListFile(QString)"),
                postproc,
                SLOT("setSurFCListFile(QString)"))

class AnaDirBox(QWidget):
    def __init__(self, parent=None):
        super(AnaDirBox, self).__init__(parent)

        Lab=QLabel("Analysis Directory")
        dirBox=DirBox()
        dirBox.setToolTip("Set your analysis directory")

        ListBtn=QComboBox()
        ListBtn.setDisabled(True)
        ListBtn.setMinimumWidth(160)

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)
        mainLayout.addWidget(Lab)
        mainLayout.addWidget(dirBox)
        mainLayout.addWidget(ListBtn)

        self.connect(dirBox, SIGNAL("update(QString)"),
                self.updatePath)
        self.connect(ListBtn, 
                SIGNAL("currentIndexChanged(int)"),
                self.updateList)
        self.dirBox=dirBox
        self.ListBtn=ListBtn

    def updatePath(self, Dir):
        self.emit(SIGNAL("updatePath(QString)"), Dir)
        if Dir.isEmpty():
            return

        self.ListBtn.setDisabled(False)
        ListDir=os.path.join(str(Dir), "scripts")
        ListInfo=QDir(ListDir)
        if ListInfo.exists():
            List=ListInfo.entryList(["*.list"],
                    QDir.Files,
                    QDir.Name)
            if not List.isEmpty():
                index=self.ListBtn.currentIndex()
                self.ListBtn.clear()
                self.ListBtn.addItems(List)
                if index==-1:
                    self.ListBtn.setCurrentIndex(0)
                else:
                    try:
                        self.ListBtn.setCurrentIndex(index)
                    except:
                        self.ListBtn.setCurrentIndex(0)
                return

        Flag=QMessageBox.question(self, 
                "No Subject List",
                "There is no subject list in %s!\nDo you want to create?" %\
                        (ListDir),
                QMessageBox.Yes|QMessageBox.No)
        if Flag==QMessageBox.Yes:
            Info=QDir(Dir)
            Subject=Info.entryList(
                    filters=QDir.Dirs|QDir.NoDotAndDotDot,
                    sort=QDir.Name)
            Subject.removeAll("scripts")
            if not ListInfo.exists():
                Info.mkdir("scripts")
            fp=open(os.path.join(
                str(ListDir), "subject.list"
                ), "w")
            fp.write(Subject.join("\n"))
            fp.close()
            self.ListBtn.addItem("subject.list")
        else:
            self.ListBtn.setDisabled(True)
            self.ListBtn.clear()

    def updateList(self, index):
        item=self.ListBtn.itemText(index)
        self.ListBtn.setToolTip(item)
        self.emit(SIGNAL("updateList(QString)"), item)

    def getDir(self):
        Dir=self.dirBox.getFile()
        return Dir

    def setDir(self, Dir):
        self.dirBox.setFile(Dir)

if __name__=='__main__':
    app=QApplication(sys.argv)
    main=main()
    main.show()

    app.exec_()
