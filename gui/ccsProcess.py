from PyQt4.QtGui import *
from PyQt4.QtCore import *
from ccsTerminal import *
import sys, os

class AnatProcess(Terminal):
    def __init__(self, parent=None):
        super(AnatProcess, self).__init__(parent)

        self.analysisDir=None
        self.subjectList=None
        self.anatDir=None
        self.anatFile=None
        self.gpu=False

        self.head=None
        self.brain=None

        self.isRefine=False
        self.refine=None

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

        if self.head is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Head Template"))
            return
        Head_Str="-head %s" % ( self.head )

        if self.brain is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Brain Template"))
            return
        Brain_Str="-brain %s" % ( self.brain )
        
        GPU_Str=""
        if self.gpu:
            GPU_Str="-gpu"

        Refine_Str=""
        if self.isRefine:
            if self.refine is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select Refine Template"))
                return
            Refine_Str="-refine %s" % ( self.refine )


        cmd="ccs_gui_02_anatproc %s %s %s %s %s %s %s %s" %\
                    (
                        ADir_Str,
                        SubjList_Str,
                        AnatDir_Str,
                        AnatName_Str,
                        Head_Str,
                        Brain_Str,
                        Refine_Str,
                        GPU_Str
                    )
        self.Process.start(cmd)

        LogDir=os.path.join(str(self.analysisDir), "scripts")
        CCSDir=os.getenv("CCSDIR")
        BinDir=os.path.join(CCSDir, "bin")

        Script=QFile(os.path.join(BinDir, "ccs_template_02_anatproc"))
        Date=QDate.currentDate()
        Time=QTime.currentTime()
        Log="AnatProc__%s_%s"\
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
        if self.gpu:
            text.replace("DoGPU=false", "DoGPU=true")
        text.replace("StandardHead=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz",
            "StandardHead=%s" % self.head)
        text.replace("StandardBrain=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz",
            "StandardBrain=%s" % self.brain)
        if self.isRefine:
            text.replace("DoRefine=false", "DoRefine=true")
            text.replace("StandardRefine=", "StandardRefine=%s" % self.refine)
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

    @pyqtSlot(bool)
    def setGPU(self, state):
        self.gpu=state

    @pyqtSlot(QString)
    def setHead(self, Str):
        if Str.isEmpty():
            Str=None
        self.head=Str

    @pyqtSlot(QString)
    def setBrain(self, Str):
        if Str.isEmpty():
            Str=None
        self.brain=Str

    @pyqtSlot(bool)
    def setIsRefine(self, state):
        self.isRefine=state

    @pyqtSlot(QString)
    def setRefine(self, Str):
        if Str.isEmpty():
            Str=None
        self.refine=Str

class CheckProcess(Terminal):
    def __init__(self, parent=None):
        super(CheckProcess, self).__init__(parent)

        self.setFrameStyle(
                QFrame.StyledPanel|QFrame.NoFrame)

        self.analysisDir=None
        self.subjectList=None
        self.anatDir=None
        self.brain=None
        self.isRefine=False
        self.func=None

        self.mode="anatsurf"

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

        if self.mode == 'anatsurf':
            if self.anatDir is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select Anatomical Directory"))
                return
            AnatDir_Str="-anat_dir %s" % ( self.anatDir )
            cmd="ccs_check_01_anatsurf %s %s %s" %\
                        (
                            ADir_Str,
                            SubjList_Str,
                            AnatDir_Str
                        )
            self.Process.start(cmd)
        
            LogDir=os.path.join(
                    str(self.analysisDir), "scripts")
            CCSDir=os.getenv("CCSDIR")
            BinDir=os.path.join(CCSDir, "bin")

            Script=QFile(os.path.join(
                BinDir, "ccs_template_check_01_anatsurf"))
            Date=QDate.currentDate()
            Time=QTime.currentTime()
            Log="CheckAnatSurf__%s_%s" %\
                    (
                        Date.toString("yyyy-MM-dd"),
                        Time.toString("hh-mm-ss")
                    )

            Log=os.path.join(LogDir, Log)
            Script.copy(Log)

            fp=open(Log, "r")
            text=QString(fp.read())
            text.replace("ADir=$( pwd )", "ADir=%s" % self.analysisDir)
            text.replace("SubjListName=subject.list", 
                "SubjListName=%s" % self.subjectList)
            text.replace("AnatDir=anat", "AnatDir=%s" % self.anatDir)
            fp.close()

            fp=open(Log, "w")
            fp.write(text)
            fp.close()
        elif self.mode=='anatfnirt':
            if self.anatDir is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select Anatomical Directory"))
                return
            AnatDir_Str="-anat_dir %s" % ( self.anatDir )

            if self.brain is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select Brain Template"))
                return
            Brain_Str="-brain %s" % ( self.brain )

            Refine_Str==""
            if self.isRefine:
                Refine_Str="-refine"

            cmd="ccs_check_02_anatfnirt %s %s %s %s %s" %\
                        (
                            ADir_Str,
                            SubjList_Str,
                            AnatDir_Str,
                            Brain_Str,
                            Refine_Str
                        )
            self.Process.start(cmd)
        
            LogDir=os.path.join(
                    str(self.analysisDir), "scripts")
            CCSDir=os.getenv("CCSDIR")
            BinDir=os.path.join(CCSDir, "bin")

            Script=QFile(os.path.join(
                BinDir, "ccs_template_check_02_anatfnirt"))
            Date=QDate.currentDate()
            Time=QTime.currentTime()
            Log="CheckAnatReg__%s_%s" %\
                    (
                        Date.toString("yyyy-MM-dd"),
                        Time.toString("hh-mm-ss")
                    )

            Log=os.path.join(LogDir, Log)
            Script.copy(Log)

            fp=open(Log, "r")
            text=QString(fp.read())
            text.replace("ADir=$( pwd )", "ADir=%s" % self.analysisDir)
            text.replace("SubjListName=subject.list", 
                "SubjListName=%s" % self.subjectList)
            text.replace("AnatDir=anat", "AnatDir=%s" % self.anatDir)
            text.replace("StandardBrain=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz",
                "StandardBrain=%s" % self.brain)
            if self.isRefine:
                text.replace("DoRefine=false", "DoRefine=true")
            fp.close()

            fp=open(Log, "w")
            fp.write(text)
            fp.close()
        elif self.mode=='funcbbregister':
            if self.anatDir is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select Functional Directory"))
                return
            FuncDir_Str="-func_dir %s" % ( self.anatDir )

            cmd="ccs_check_03_funcbbregister %s %s %s" %\
                        (
                            ADir_Str,
                            SubjList_Str,
                            FuncDir_Str
                        )
            self.Process.start(cmd)
        
            LogDir=os.path.join(
                    str(self.analysisDir), "scripts")
            CCSDir=os.getenv("CCSDIR")
            BinDir=os.path.join(CCSDir, "bin")

            Script=QFile(os.path.join(
                BinDir, "ccs_template_check_03_funcbbregister"))
            Date=QDate.currentDate()
            Time=QTime.currentTime()
            Log="CheckFuncBBR__%s_%s" %\
                    (
                        Date.toString("yyyy-MM-dd"),
                        Time.toString("hh-mm-ss")
                    )

            Log=os.path.join(LogDir, Log)
            Script.copy(Log)

            fp=open(Log, "r")
            text=QString(fp.read())
            text.replace("ADir=$( pwd )", "ADir=%s" % self.analysisDir)
            text.replace("SubjListName=subject.list", 
                "SubjListName=%s" % self.subjectList)
            text.replace("FuncDir=func", "FuncDir=%s" % self.anatDir)
            fp.close()

            fp=open(Log, "w")
            fp.write(text)
            fp.close()
        elif self.mode=='funcfnirt':
            if self.anatDir is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select Functional Directory"))
                return
            FuncDir_Str="-func_dir %s" % ( self.anatDir )

            if self.func is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select EPI Template"))
                return
            EPI_Str="-epi %s" % ( self.func )
        
            cmd="ccs_check_04_funcfnirt %s %s %s %s" %\
                        (
                            ADir_Str,
                            SubjList_Str,
                            FuncDir_Str,
                            EPI_Str
                        )
            self.Process.start(cmd)
        
            LogDir=os.path.join(
                    str(self.analysisDir), "scripts")
            CCSDir=os.getenv("CCSDIR")
            BinDir=os.path.join(CCSDir, "bin")

            Script=QFile(os.path.join(
                BinDir, "ccs_template_check_04_funcfnirt"))
            Date=QDate.currentDate()
            Time=QTime.currentTime()
            Log="CheckFuncReg__%s_%s" %\
                    (
                        Date.toString("yyyy-MM-dd"),
                        Time.toString("hh-mm-ss")
                    )

            Log=os.path.join(LogDir, Log)
            Script.copy(Log)

            fp=open(Log, "r")
            text=QString(fp.read())
            text.replace("ADir=$( pwd )", "ADir=%s" % self.analysisDir)
            text.replace("SubjListName=subject.list", 
                "SubjListName=%s" % self.subjectList)
            text.replace("FuncDir=func", "FuncDir=%s" % self.anatDir)
            text.replace("StandardEPI=$CCSDIR/bin/templates/MNI152_T1_3mm_brain.nii.gz",
                "StandardEPI=%s" % self.func)
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
    def setBrain(self, Str):
        if Str.isEmpty():
            Str=None
        self.brain=Str

    @pyqtSlot(bool)
    def setIsRefine(self, state):
        self.isRefine=state

    @pyqtSlot(QString)
    def setFunc(self, Str):
        if Str.isEmpty():
            Str=None
        self.func=Str

class SurfCheck(QFrame):
    def __init__(self, parent=None):
        super(SurfCheck, self).__init__(parent)
        self.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)

        terminal=CheckProcess()

        ImageList=QStringList()
        ImageList.append(
                QString("axial.png"))
        ImageList.append(
                QString("coronal.png"))
        ImageList.append(
                QString("sagittal.png"))
        ImageList.append(
                QString("summary.png"))
        
        SubjLab=QLabel("Subject (Check Surf Recon):")
        List=QListWidget()

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
        mainSplitter.addWidget(terminal)

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
        mainSplitter.setStretchFactor(0, 1)

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
         
        self.connect(PreviousBtn, SIGNAL("clicked()"),
                self.previousSubj)
        self.connect(NextBtn, SIGNAL("clicked()"),
                self.nextSubj)

        self.connect(LeftBtn, SIGNAL("clicked()"),
                self.leftImage)
        self.connect(RightBtn, SIGNAL("clicked()"),
                self.rightImage)

        self.SubjLab=SubjLab

        self.List=List
        self.PreviousBtn=PreviousBtn
        self.NextBtn=NextBtn
        self.ViewArea=ViewArea
        self.ImageLab=ImageLab
        self.LeftBtn=LeftBtn
        self.RightBtn=RightBtn

        self.timer=timer
        self.terminal=terminal

        self.analysisDir=None
        self.anatDir=None
        self.path=None
        self.subjectList=None
        self.subjectIndex=None
        self.imageIndex=None
        self.imageList=ImageList
        self.checkListName="check_anatsurf.list"

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
                self.checkListName)
        Info=QFileInfo(File)
        if not Info.exists():
            self.List.clear()
            self.ImageLab.setText(QString())
            self.ViewArea.setPixmap(None)
            #self.CheckBtn.setDisabled(True)
            self.PreviousBtn.setDisabled(True) 
            self.NextBtn.setDisabled(True) 
            self.LeftBtn.setDisabled(True) 
            self.RightBtn.setDisabled(True) 
            return

        #self.CheckBtn.setDisabled(True)
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

class RegCheck(SurfCheck):
    def __init__(self, parent=None):
        super(RegCheck, self).__init__(parent)

        self.SubjLab.setText("Subject (Check Anat Reg):")

        self.imageList=QStringList()
        self.imageList.append(
                QString("fnirt_highres2standard.png"))

        self.checkListName="check_anatfnirt.list"
        self.terminal.mode="anatfnirt"

    def setPath(self):
        subj=self.subjectList[self.subjectIndex]
        self.subjectPath=os.path.join(
                str(self.analysisDir), str(subj))
        self.path=os.path.join(
                str(self.subjectPath),
                str(self.anatDir),
                "reg",
                "vcheck"
                )

class MainAnat(QFrame):
    def __init__(self, parent=None):
        super(MainAnat, self).__init__(parent)
        
        terminal=AnatProcess()
        surf_check=SurfCheck()
        reg_check=RegCheck()

        mainSplitter=QSplitter(Qt.Vertical)
        mainSplitter.addWidget(terminal)
        mainSplitter.addWidget(surf_check)
        mainSplitter.addWidget(reg_check)

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
        self.surf_check=surf_check
        self.reg_check=reg_check

    def timeStart(self):
        self.surf_check.timer.start(30000)
        self.reg_check.timer.start(30000)
    def timeStop(self, exitCode):
        self.surf_check.timer.stop()
        self.reg_check.timer.stop()

    def updateCheck(self, exitCode, exitState):
        if not exitCode and not exitState:
            self.surf_check.setList()
            self.reg_check.setList()
        
class FuncProcess(Terminal):
    def __init__(self, parent=None):
        super(FuncProcess, self).__init__(parent)

        self.analysisDir=None
        self.subjectList=None
        self.anatDir=None
        self.funcDir=None
        self.funcFile=None
        self.TR=None
        self.dropNum=None
        self.tpattern=QString("alt+z")

        self.bandLow=None
        self.bandHigh=None

        self.func=None
        self.surface=QString("fsaverage5")

        self.isRefine=False
        self.refine=None

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

        if self.funcDir is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Functional Directory"))
            return
        FuncDir_Str="-func_dir %s" % ( self.funcDir )

        if self.funcFile is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Functional Name"))
            return
        FuncName_Str="-func_name %s" % ( self.funcFile )

        if self.TR is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select TR"))
            return
        TR_Str="-tr %s" % ( self.TR )

        if self.dropNum is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Drop Number"))
            return
        DropNum_Str="-drop_num %s" % ( self.dropNum )

        SliceOrder_Str="-slice_order %s" % self.tpattern

        if self.bandLow is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Low Band"))
            return
        BandLow_Str="-band_low %s" % ( self.bandLow )

        if self.bandHigh is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select High Band"))
            return
        BandHigh_Str="-band_high %s" % ( self.bandHigh )

        if self.func is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select EPI Template"))
            return
        EPI_Str="-epi %s" % ( self.func )

        Surface_Str="-surface %s" % self.surface

        Refine_Str=""
        if self.isRefine:
            if self.refine is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select Refine Template"))
                return
            Refine_Str="-refine %s" % ( self.refine )

        cmd="ccs_gui_03_funcproc %s %s %s %s %s %s %s %s %s %s %s %s %s" %\
                    (
                        ADir_Str,
                        SubjList_Str,
                        AnatDir_Str,
                        FuncDir_Str,
                        FuncName_Str,
                        TR_Str,
                        DropNum_Str,
                        SliceOrder_Str,
                        BandLow_Str,
                        BandHigh_Str,
                        EPI_Str,
                        Surface_Str,
                        Refine_Str
                    )
        self.Process.start(cmd)

        LogDir=os.path.join(str(self.analysisDir), "scripts")
        CCSDir=os.getenv("CCSDIR")
        BinDir=os.path.join(CCSDir, "bin")

        Script=QFile(os.path.join(BinDir, "ccs_template_03_funcproc"))
        Date=QDate.currentDate()
        Time=QTime.currentTime()
        Log="FuncProc__%s_%s"\
            %(Date.toString("yyyy-MM-dd"),Time.toString("hh-mm-ss"))
        Log=os.path.join(LogDir, Log)
        Script.copy(Log)

        fp=open(Log, "r")
        text=QString(fp.read())
        text.replace("ADir=$( pwd )", "ADir=%s" % self.analysisDir)
        text.replace("SubjListName=subject.list",
            "SubjListName=%s" % self.subjectList)
        text.replace("AnatDir=anat", "AnatDir=%s" % self.anatDir)
        text.replace("FuncDir=func", "FuncDir=%s" % self.funcDir)
        text.replace("FuncName=rest", "FuncName=%s" % self.funcFile)
        text.replace("TR=3", "TR=%s" % self.TR)
        text.replace("DropNum=5", "DropNum=%s" % self.dropNum)
        text.replace("SliceOrder=alt+z", "SliceOrder=%s" % self.tpattern)
        text.replace("BandLow=0.01", "BandLow=%s" % self.bandLow)
        text.replace("BandHigh=0.08", "BandHigh=%s" % self.bandHigh)
        text.replace("StandardSurface=fsaverage5", 
            "StandardSurface=%s" % self.surface)
        text.replace("StandardEPI=$CCSDIR/bin/templates/MNI152_T1_3mm_brain.nii.gz",
            "StandardEPI=%s" % self.func)
        if self.isRefine:
            text.replace("DoRefine=false", "DoRefine=true")
            text.replace("StandardRefine=", "StandardRefine=%s" % self.refine)
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
    def setFuncDir(self, Str):
        if Str.isEmpty():
            Str=None
        self.funcDir=Str

    @pyqtSlot(QString)
    def setFuncFile(self, Str):
        if Str.isEmpty():
            Str=None
        self.funcFile=Str

    @pyqtSlot(QString)
    def setTR(self, Str):
        if Str.isEmpty():
            Str=None
        self.TR=Str

    @pyqtSlot(QString)
    def setDropNum(self, Str):
        if Str.isEmpty():
            Str=None
        self.dropNum=Str

    @pyqtSlot(QString)
    def setTPattern(self, Str):
        self.tpattern=Str

    @pyqtSlot(QString)
    def setBandLow(self, Str):
        if Str.isEmpty():
            Str=None
        self.bandLow=Str

    @pyqtSlot(QString)
    def setBandHigh(self, Str):
        if Str.isEmpty():
            Str=None
        self.bandHigh=Str

    @pyqtSlot(QString)
    def setFunc(self, Str):
        if Str.isEmpty():
            Str=None
        self.func=Str

    @pyqtSlot(QString)
    def setSurface(self, Str):
        if Str.isEmpty():
            Str=None
        self.surface=Str

    @pyqtSlot(bool)
    def setIsRefine(self, state):
        self.isRefine=state

    @pyqtSlot(QString)
    def setRefine(self, Str):
        if Str.isEmpty():
            Str=None
        self.refine=Str

class BBCheck(SurfCheck):
    def __init__(self, parent=None):
        super(BBCheck, self).__init__(parent)

        self.SubjLab.setText("Subject (Check Func BB):")

        self.checkListName="check_funcbbregister.list"
        self.terminal.mode="funcbbregister"

    def setPath(self):
        subj=self.subjectList[self.subjectIndex]
        self.subjectPath=os.path.join(
                str(self.analysisDir), str(subj))
        self.path=os.path.join(
                str(self.subjectPath), 
                str(self.anatDir),
                "reg", "vcheck")

class EPICheck(SurfCheck):
    def __init__(self, parent=None):
        super(EPICheck, self).__init__(parent)

        self.SubjLab.setText("Subject (Check Func Reg):")

        self.imageList=QStringList()
        self.imageList.append(
                QString("fnirt_example_func2standard.png"))

        self.checkListName="check_funcfnirt.list"
        self.terminal.mode="funcfnirt"

    def setPath(self):
        subj=self.subjectList[self.subjectIndex]
        self.subjectPath=os.path.join(
                str(self.analysisDir), str(subj))
        self.path=os.path.join(
                str(self.subjectPath), 
                str(self.anatDir),
                "reg", "vcheck")

class MainFunc(QFrame):
    def __init__(self, parent=None):
        super(MainFunc, self).__init__(parent)
        
        terminal=FuncProcess()
        bbr_check=BBCheck()
        reg_check=EPICheck()

        mainSplitter=QSplitter(Qt.Vertical)
        mainSplitter.addWidget(terminal)
        mainSplitter.addWidget(bbr_check)
        mainSplitter.addWidget(reg_check)

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
        self.bbr_check=bbr_check
        self.reg_check=reg_check

    def timeStart(self):
        self.bbr_check.timer.start(30000)
        self.reg_check.timer.start(30000)
    def timeStop(self, exitCode):
        self.bbr_check.timer.stop()
        self.reg_check.timer.stop()

    def updateCheck(self, exitCode, exitState):
        if not exitCode and not exitState:
            self.bbr_check.setList()
            self.reg_check.setList()
        
class PostProcess(Terminal):
    def __init__(self, parent=None):
        super(PostProcess, self).__init__(parent)

        self.analysisDir=None
        self.subjectList=None

        self.anatDir=None
        self.funcDir=None
        self.funcFile=None

        self.func=None
        self.surface=QString("fsaverage5")

        self.isRefine=False
        self.refine=QString()
        self.TR=None

        self.VolState=False

        self.VolReHoState=False
        self.VolALFFState=False
        self.VolVMHCState=False
        self.VolDCState=False
        self.VolECState=False
        self.VolBCState=False
        self.VolPCState=False
        self.VolVNCM_P=None
        self.VolFCState=False
        self.VolFCListFile=None

        self.SurState=False

        self.SurReHoState=False
        self.SurALFFState=False
        self.SurVMHCState=False
        self.SurDCState=False
        self.SurECState=False
        self.SurBCState=False
        self.SurPCState=False
        self.SurVNCM_P=None
        self.SurFCState=False
        self.SurFCListFile=None

    def start(self):
        Refine_Str=""

        Vol_Str=""

        VolReHo_Str=""
        VolALFF_Str=""
        VolVMHC_Str=""
        VolVNCM_Str=""
        VolFC_Str=""

        Sur_Str=""

        SurReHo_Str=""
        SurALFF_Str=""
        SurVMHC_Str=""
        SurVNCM_Str=""
        SurFC_Str=""

        if self.analysisDir is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Analysis Directory"))
            return
        else:
            ADir_Str="-analysis_dir %s" % ( self.analysisDir )

        if self.subjectList is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please create Subject List"))
            return
        else:
            SubjList_Str="-subj_list %s" % ( self.subjectList )

        if self.anatDir is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Anatomical Directory"))
            return
        AnatDir_Str="-anat_dir %s" % ( self.anatDir )

        if self.funcDir is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Functional Directory"))
            return
        FuncDir_Str="-func_dir %s" % ( self.funcDir )

        if self.funcFile is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Functional Name"))
            return
        FuncName_Str="-func_name %s" % ( self.funcFile )

        if self.func is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select EPI Template"))
            return
        EPI_Str="-epi %s" % ( self.func )

        Surface_Str="-surface %s" % self.surface

        if self.isRefine:
            if self.refine is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select Refine Template"))
                return
            Refine_Str="-refine %s" % ( self.refine )

        if self.TR is None:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select TR"))
            return
        TR_Str="-tr %s" % ( self.TR )

        if not self.VolState and not self.SurState:
            QMessageBox.critical(self, "Input Error",
                    self.tr("Please select Volume or Surface"))
            return

        if self.VolState:
            Vol_Str="-do_volume"

        if self.VolALFFState:
            VolALFF_Str="-vol_alff"

        if self.VolReHoState:
            VolReHo_Str="-vol_reho"

        if self.VolVMHCState:
            VolVMHC_Str="-vol_vmhc"

        if self.VolDCState or self.VolECState\
                or self.VolBCState or self.VolPCState:
            if self.VolVNCM_P is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select p value of PC"))
                return
            VolVNCM_Str="-vol_vncm \"%d %d %d %d\" %s" %\
                            (
                            self.VolDCState,
                            self.VolECState,
                            self.VolBCState,
                            self.VolPCState,
                            self.VolVNCM_P
                            )
        if self.VolFCState:
            if self.VolFCListFile is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select ROIs for FC"))
                return
            VolFC_Str="-vol_fc %s"  % ( self.VolFCListFile )

        if self.SurState:
            Sur_Str="-do_surface"

        if self.SurALFFState:
            SurALFF_Str="-sur_alff"

        if self.SurReHoState:
            SurReHo_Str="-sur_reho"

        if self.SurVMHCState:
            SurVMHC_Str="-sur_vmhc"

        if self.SurDCState or self.SurECState\
                or self.SurBCState or self.SurPCState:
            if self.SurVNCM_P is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select p value of PC"))
                return
            SurVNCM_Str="-sur_vncm \"%d %d %d %d\" %s" %\
                            (
                            self.SurDCState,
                            self.SurECState,
                            self.SurBCState,
                            self.SurPCState,
                            self.SurVNCM_P
                            )

        if self.SurFCState:
            if self.SurFCListFile is None:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Please select ROIs for FC"))
                return
            SurFC_Str="-sur_fc %s"  % ( self.SurFCListFile )

        cmd="ccs_gui_04_postproc %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s" %\
                    (
                        ADir_Str,
                        SubjList_Str,
                        AnatDir_Str,
                        FuncDir_Str,
                        FuncName_Str,
                        EPI_Str,
                        Surface_Str,
                        Refine_Str,
                        TR_Str,
                        Vol_Str,
                        VolALFF_Str,
                        VolReHo_Str,
                        VolVMHC_Str,
                        VolVNCM_Str,
                        VolFC_Str,
                        Sur_Str,
                        SurALFF_Str,
                        SurReHo_Str,
                        SurVMHC_Str,
                        SurVNCM_Str,
                        SurFC_Str,
                    )

        self.Process.start(cmd)

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
    def setFuncDir(self, Str):
        if Str.isEmpty():
            Str=None
        self.funcDir=Str

    @pyqtSlot(QString)
    def setFuncFile(self, Str):
        if Str.isEmpty():
            Str=None
        self.funcFile=Str

    @pyqtSlot(QString)
    def setFunc(self, Str):
        if Str.isEmpty():
            Str=None
        self.func=Str

    @pyqtSlot(QString)
    def setSurface(self, Str):
        if Str.isEmpty():
            Str=None
        self.surface=Str

    @pyqtSlot(bool)
    def setIsRefine(self, state):
        self.isRefine=state

    @pyqtSlot(QString)
    def setRefine(self, Str):
        if Str.isEmpty():
            Str=None
        self.refine=Str

    @pyqtSlot(QString)
    def setTR(self, Str):
        if Str.isEmpty():
            Str=None
        self.TR=Str

    @pyqtSlot(bool)
    def setVolState(self, state):
        self.VolState=state

    @pyqtSlot(bool)
    def setVolReHoState(self, state):
        self.VolReHoState=state

    @pyqtSlot(bool)
    def setVolALFFState(self, state):
        self.VolALFFState=state

    @pyqtSlot(bool)
    def setVolVMHCState(self, state):
        self.VolVMHCState=state

    @pyqtSlot(bool)
    def setVolDCState(self, state):
        self.VolDCState=state

    @pyqtSlot(bool)
    def setVolECState(self, state):
        self.VolECState=state

    @pyqtSlot(bool)
    def setVolBCState(self, state):
        self.VolBCState=state

    @pyqtSlot(bool)
    def setVolPCState(self, state):
        self.VolPCState=state

    @pyqtSlot(QString)
    def setVolVNCMPValue(self, Str):
        if Str.isEmpty():
            Str=None
        self.VolVNCM_P=Str

    @pyqtSlot(bool)
    def setVolFCState(self, state):
        self.VolFCState=state

    @pyqtSlot(QString)
    def setVolFCListFile(self, Str):
        if Str.isEmpty():
            Str=None
        self.VolFCListFile=Str

    @pyqtSlot(bool)
    def setSurState(self, state):
        self.SurState=state

    @pyqtSlot(bool)
    def setSurReHoState(self, state):
        self.SurReHoState=state

    @pyqtSlot(bool)
    def setSurALFFState(self, state):
        self.SurALFFState=state

    @pyqtSlot(bool)
    def setSurVMHCState(self, state):
        self.SurVMHCState=state

    @pyqtSlot(bool)
    def setSurDCState(self, state):
        self.SurDCState=state

    @pyqtSlot(bool)
    def setSurECState(self, state):
        self.SurECState=state

    @pyqtSlot(bool)
    def setSurBCState(self, state):
        self.SurBCState=state

    @pyqtSlot(bool)
    def setSurPCState(self, state):
        self.SurPCState=state

    @pyqtSlot(QString)
    def setSurVNCMPValue(self, Str):
        if Str.isEmpty():
            Str=None
        self.SurVNCM_P=Str

    @pyqtSlot(bool)
    def setSurFCState(self, state):
        self.SurFCState=state

    @pyqtSlot(QString)
    def setSurFCListFile(self, Str):
        if Str.isEmpty():
            Str=None
        self.SurFCListFile=Str

if __name__=='__main__':
    app=QApplication(sys.argv)
    main=MainAnat()
    main.show()
    app.exec_()
