from PyQt4.QtGui import *
from PyQt4.QtCore import *
from ccsBase import *
from ccsTerminal import *
import sys, os

class SelectDlg(QDialog):
    def __init__(self, parent=None):
        super(SelectDlg, self).__init__(parent)

        #manualBtn=QCheckBox("Manual Skull Stripping  ")
        fsBtn=QPushButton("Free Surfer Strip")
        looseBtn=QPushButton("FSL Loose Strip")
        tightBtn=QPushButton("FSL Tight Strip")

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(8)
        mainLayout.setSpacing(0)
        mainLayout.addWidget(fsBtn)
        mainLayout.addWidget(looseBtn)
        mainLayout.addWidget(tightBtn)

        self.connect(fsBtn, SIGNAL("clicked()"),
                self.selectFS)
        self.connect(looseBtn, SIGNAL("clicked()"),
                self.selectLoose)
        self.connect(tightBtn, SIGNAL("clicked()"),
                self.selectTight)

    def selectFS(self):
        self.done(1)

    def selectLoose(self):
        self.done(2)

    def selectTight(self):
        self.done(3)

class SkullProcess(Terminal):
    def __init__(self, parent=None):
        super(SkullProcess, self).__init__(parent)

        self.analysisDir=None
        self.subjectList=None
        self.anatDir=None
        self.anatFile=None
        self.scansNum=None
        self.gcut=False
        self.denoised=False

    def start(self):
        if self.analysisDir is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Analysis Directory"))
            return
        ADir_Str="-analysis_dir %s" % ( self.analysisDir )

        if self.subjectList is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please create Subject List"))
            return
        SubjList_Str="-subj_list %s" % ( self.subjectList )

        if self.anatDir is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Anatomical Directory"))
            return
        AnatDir_Str="-anat_dir %s" % ( self.anatDir )

        if self.anatFile is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Anatomical Name"))
            return
        AnatName_Str="-anat_name %s" % ( self.anatFile )

        Denoised_Str=""
        if self.denoised:
            Denoised_Str="-denoised"

        GCut_Str=""
        if self.gcut:
            GCut_Str="-gcut"

        if self.scansNum is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Scans Number"))
            return
        ScansNum_Str="-scans_num %s" % ( self.scansNum )

        cmd="ccs_gui_01_anatskullstrip %s %s %s %s %s %s %s" %\
                    (
                        ADir_Str,
                        SubjList_Str,
                        AnatDir_Str,
                        AnatName_Str,
                        Denoised_Str,
                        GCut_Str,
                        ScansNum_Str 
                    )
        self.Process.start(cmd)
        
        LogDir=os.path.join(str(self.analysisDir), "scripts")
        CCSDir=os.getenv("CCSDIR")
        BinDir=os.path.join(CCSDir, "bin")

        Script=QFile(os.path.join(BinDir, "ccs_template_01_anatskullstrip"))
        Date=QDate.currentDate()
        Time=QTime.currentTime()
        Log="AnatSkullStrip__%s_%s"\
            %(Date.toString("yyyy-MM-dd"),Time.toString("hh-mm-ss"))
        Log=os.path.join(LogDir, Log)
        Script.copy(Log)

        fp=open(Log, "r")
        text=QString(fp.read())
        text.replace("ADir=$( pwd )", "ADir=%s" % self.analysisDir)
        text.replace("SubjListName=subject.list", 
                "SubjListName=%s" % self.subjectList)
        text.replace("AnatDir=anat", "AnatDir=%s" % self.anatDir)
        text.replace("AnatName=mprage", "AnatName=%s" % self.anatFile)
        if self.denoised:
            text.replace("DoDenoise=false", "DoDenoise=true")
        if self.gcut:
            text.replace("DoGCut=false", "DoGCut=true")
        text.replace("ScansNum=1", "ScansNum=%s" % self.scansNum)
        fp.close()

        fp=open(Log, "w")
        fp.write(text)
        fp.close()

    @pyqtSlot(QString)
    def setAnalysisDir(self, Str):
        if Str.isEmpty():
            Str=None
        self.analysisDir=Str

    @pyqtSlot(QString)
    def setSubjectList(self, Str):
        if Str.isEmpty():
            Str=None
        self.subjectList=Str

    @pyqtSlot(QString)
    def setAnatDir(self, Str):
        if Str.isEmpty():
            Str=None
        self.anatDir=Str

    @pyqtSlot(QString)
    def setAnatFile(self, Str):
        if Str.isEmpty():
            Str=None
        self.anatFile=Str

    @pyqtSlot(QString)
    def setScansNum(self, Str):
        if Str.isEmpty():
            Str=None
        self.scansNum=Str

    @pyqtSlot(bool)
    def setGcut(self, state):
        self.gcut=state

    @pyqtSlot(bool)
    def setDenoised(self, state):
        self.denoised=state

class SkullStrip(QFrame):
    def __init__(self, parent=None):
        super(SkullStrip, self).__init__(parent)
        self.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)

        ImageList=QStringList()
        ImageList.append(
                QString("skull_fs_strip.png"))
        ImageList.append(
                QString("skull_loose_strip.png"))
        ImageList.append(
                QString("skull_loose_strip_diff.png"))
        ImageList.append(
                QString("skull_tight_strip.png"))
        ImageList.append(
                QString("skull_tight_strip_diff.png"))
        
        SubjLab=QLabel("Subject (Check Skull Strip):")
        List=QListWidget()

        SelectBtn=QPushButton("Select")
        SelectBtn.setDisabled(True)
        EditBtn=QPushButton("Edit")
        EditBtn.setDisabled(True)
        FinishBtn=QPushButton("Finish")
        FinishBtn.setDisabled(True)
        PreviousBtn=QPushButton("<< Previous Subject")
        PreviousBtn.setDisabled(True)
        NextBtn=QPushButton("Next Subject >>")
        NextBtn.setDisabled(True)

        ViewArea=ImageView()

        LeftBtn=QPushButton("<<")
        LeftBtn.setDisabled(True)
        RightBtn=QPushButton(">>")
        RightBtn.setDisabled(True)
        ImageLab=QLabel("No Image")
        ImageLab.setMinimumWidth(200)
        ImageLab.setAlignment(Qt.AlignCenter)
        ImageLab.setFrameStyle(
                QFrame.StyledPanel|QFrame.Sunken)

        mainSplitter=QSplitter(Qt.Horizontal)

        leftLayout=FrameLayout(
                direction=QBoxLayout.TopToBottom)
        leftLayout.addChildWidget(SubjLab)
        leftLayout.addChildWidget(List)
        mainSplitter.addWidget(leftLayout)

        rightLayout=FrameLayout(
                direction=QBoxLayout.TopToBottom)

        HBox=QHBoxLayout()
        HBox.setMargin(0)
        HBox.setSpacing(0)
        HBox.addWidget(SelectBtn)
        HBox.addWidget(EditBtn)
        HBox.addWidget(FinishBtn)
        HBox.addStretch()
        HBox.addWidget(PreviousBtn)
        HBox.addWidget(NextBtn)
        rightLayout.addChildLayout(HBox)
    
        rightLayout.addChildWidget(ViewArea)

        HBox=QHBoxLayout()
        HBox.setMargin(0)
        HBox.setSpacing(0)
        HBox.addStretch()
        HBox.addWidget(LeftBtn)
        HBox.addWidget(ImageLab)
        HBox.addWidget(RightBtn)
        HBox.addStretch()
        rightLayout.addChildLayout(HBox)
        mainSplitter.addWidget(rightLayout)

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(0)
        mainLayout.setSpacing(0)
        mainLayout.addWidget(mainSplitter)

        timer=QTimer(self)

        self.connect(timer,
                SIGNAL("timeout()"), self.setList)

        self.connect(List, 
                SIGNAL("currentRowChanged(int)"),
                self.changeSubj)
         
        self.connect(SelectBtn, SIGNAL("clicked()"),
                self.selectImage)
        self.connect(EditBtn, SIGNAL("clicked()"),
                self.editImage)
        self.connect(FinishBtn, SIGNAL("clicked()"),
                self.finishImage)
        self.connect(PreviousBtn, SIGNAL("clicked()"),
                self.previousSubj)
        self.connect(NextBtn, SIGNAL("clicked()"),
                self.nextSubj)

        self.connect(LeftBtn, SIGNAL("clicked()"),
                self.leftImage)
        self.connect(RightBtn, SIGNAL("clicked()"),
                self.rightImage)

        self.List=List
        self.SelectBtn=SelectBtn
        self.EditBtn=EditBtn
        self.FinishBtn=FinishBtn
        self.PreviousBtn=PreviousBtn
        self.NextBtn=NextBtn
        self.ViewArea=ViewArea
        self.ImageLab=ImageLab
        self.LeftBtn=LeftBtn
        self.RightBtn=RightBtn

        self.timer=timer

        self.analysisDir=None
        self.anatDir=None
        self.path=None
        self.subjectList=None
        self.subjectIndex=None
        self.imageIndex=None
        self.imageList=ImageList

    def changeSubj(self, index):
        self.subjectIndex=index

        self.NextBtn.setDisabled(False)
        self.PreviousBtn.setDisabled(False)
        if index==0:
            self.PreviousBtn.setDisabled(True)
        if index==self.subjectList.count()-1:
            self.NextBtn.setDisabled(True)

        self.setPath()
        self.setImage()

    def selectImage(self):
        maskList=["brainmask.fsinit.mgz",
                "brainmask.loose.mgz",
                "brainmask.tight.mgz"]
        dlg=SelectDlg(self)
        state=dlg.exec_()
        if state:
            mask=maskList[state-1]
            maskPath=self.filepath
            maskFile=QFile(os.path.join(str(maskPath), str(mask)))
            editFile=os.path.join(str(maskPath), "brainmask.edit.mgz")
            maskFile.copy(editFile)
            self.editMtime=os.path.getmtime(editFile)
            self.EditBtn.setDisabled(False)
            self.FinishBtn.setDisabled(False)

    def editImage(self):
        maskPath=self.filepath
        editFile=os.path.join(str(maskPath), "brainmask.edit.mgz")
        editInfo=QFile(editFile)
        if not editInfo.exists():
            QMessageBox.critical(self, "No File!",
                    self.tr("Please select first!"))
            return
        p=QProcess(self)
        os.putenv("SUBJECTS_DIR", str(self.analysisDir))
        subj=self.subjectList[self.subjectIndex]
        p.start("tkmedit %s brainmask.edit.mgz " % subj+
                "-aux T1.mgz")
        while True:
            if p.waitForFinished(-1): break

        mtime=os.path.getmtime(editFile)
        if mtime!=self.editMtime:
            self.FinishBtn.setDisabled(False)

    def finishImage(self):
        maskPath=self.filepath
        editFile=QFile(os.path.join(str(maskPath), "brainmask.edit.mgz"))
        finishFile=os.path.join(str(maskPath), "brainmask.mgz")
        editFile.copy(finishFile)
        
        index=self.subjectIndex+1
        if index==self.subjectList.count():
	        index=index-1
        self.changeSubj(index)
        self.List.setCurrentRow(index)

        self.FinishBtn.setDisabled(True)

    def previousSubj(self):
        index=self.subjectIndex-1
        self.changeSubj(index)
        self.List.setCurrentRow(index)

    def nextSubj(self):
        index=self.subjectIndex+1
        self.changeSubj(index)
        self.List.setCurrentRow(index)

    def leftImage(self):
        index=self.imageIndex-1
        self.imageIndex=index
        self.setImage()

    def rightImage(self):
        index=self.imageIndex+1
        self.imageIndex=index
        self.setImage()

    def setList(self):
        File=os.path.join(str(self.analysisDir),\
                "scripts",\
                "check_skullstrip.list")
        Info=QFileInfo(File)
        if not Info.exists():
            self.List.clear()
            self.ImageLab.setText(QString())
            self.ViewArea.setPixmap(None)
            self.SelectBtn.setDisabled(True) 
            self.EditBtn.setDisabled(True) 
            self.FinishBtn.setDisabled(True) 
            self.PreviousBtn.setDisabled(True) 
            self.NextBtn.setDisabled(True) 
            self.LeftBtn.setDisabled(True) 
            self.RightBtn.setDisabled(True) 
            return

        fp=open(File, "r")
        subjectList=QStringList(fp.readlines())
        fp.close()
        subjectList.replaceInStrings("\n", "")
        self.List.blockSignals(True)
        self.List.clear()
        self.List.addItems(subjectList)

        self.subjectList=subjectList
        if self.subjectIndex is None:
            self.subjectIndex=0
            self.PreviousBtn.setDisabled(True) 
            self.NextBtn.setDisabled(False) 

        if self.imageIndex is None:
            self.imageIndex=0
            self.LeftBtn.setDisabled(True)
            self.RightBtn.setDisabled(False) 

        self.List.blockSignals(False)
        self.changeSubj(self.subjectIndex)
        self.List.setCurrentRow(self.subjectIndex)

    def setPath(self):
        subj=self.subjectList[self.subjectIndex]
        self.subjectPath=os.path.join(
                str(self.analysisDir), str(subj))
        self.path=os.path.join(
                str(self.subjectPath),
                str(self.anatDir),
                "vcheck")
        self.filepath=os.path.join(
                str(self.subjectPath), "mri")
        editFile=os.path.join(
                str(self.filepath), "brainmask.edit.mgz")
        editInfo=QFile(editFile)
        self.SelectBtn.setDisabled(False)
        if editInfo.exists():
            self.EditBtn.setDisabled(False)
            self.FinishBtn.setDisabled(False)
            self.editMtime=os.path.getmtime(editFile)
        else:
            self.EditBtn.setDisabled(True)
            self.FinishBtn.setDisabled(True)

        finishFile=QFile(os.path.join(
            str(self.filepath), "brainmask.mgz")
            )
        if finishFile.exists():
            self.FinishBtn.setDisabled(True)

    def setImage(self):
        self.RightBtn.setDisabled(False)
        self.LeftBtn.setDisabled(False)
        if self.imageIndex==0:
            self.LeftBtn.setDisabled(True)
        if self.imageIndex==self.imageList.count()-1:
            self.RightBtn.setDisabled(True)

        image=self.imageList[self.imageIndex]
        self.ImageLab.setText(image)
        image=os.path.join(str(self.path), str(image))
        self.ViewArea.setPixmap(image)
        #print(image)

    @pyqtSlot(QString)
    def setAnatDir(self, anatDir):
        self.anatDir=anatDir
        if not self.analysisDir is None:
            self.setList()

    @pyqtSlot(QString)
    def setAnalysisDir(self, analysisDir):
        self.analysisDir=analysisDir
        if not self.anatDir is None:
            self.setList()

class MainSkull(QFrame):
    def __init__(self, parent=None):
        super(MainSkull, self).__init__(parent)
        
        terminal=SkullProcess()
        check=SkullStrip()

        mainSplitter=QSplitter(Qt.Vertical)
        mainSplitter.addWidget(terminal)
        mainSplitter.addWidget(check)

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(0)
        mainLayout.setSpacing(0)
        mainLayout.addWidget(mainSplitter)

        self.connect(terminal.Process,
                SIGNAL("started()"),
                self.timeStart)
        self.connect(terminal.Process,
                SIGNAL("finished(int)"),
                self.timeStop)
        self.connect(terminal.Process, 
                SIGNAL("finished(int, QProcess::ExitStatus)"),
                self.updateCheck)

        self.terminal=terminal
        self.check=check

    def timeStart(self):
        self.check.timer.start(30000)
    def timeStop(self, exitCode):
        self.check.timer.stop()

    def updateCheck(self, exitCode, exitState):
        if not exitCode and not exitState:
            self.check.setList()
        
if __name__=='__main__':
    app=QApplication(sys.argv)
    main=MainSkull()
    main.show()
    app.exec_()
