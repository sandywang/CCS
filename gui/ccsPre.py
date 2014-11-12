from PyQt4.QtGui import *
from PyQt4.QtCore import *
from ccsBase import *
from ConfigParser import *
import sys, os

class AnatDir(ValueBox):
    def __init__(self, parent=None):
        super(AnatDir, self).__init__(parent)
        self.changeToOther("Anat Directory",
                """
The name of directory where the anatomical images are put in.
                """
                )
        self.setFixedWidth(120)
        self.Ety.setMinimumWidth(80)

    def editValue(self):
        value=checkValue(self.value, self.Ety, "s")
        if not value is None:
            Str=QString(str(value))
            if Str.isEmpty():
                self.value=None
            else:
                self.value=value
                self.emit(SIGNAL("update(QString)"), Str)

class AnatFile(ValueBox):
    def __init__(self, parent=None):
        super(AnatFile, self).__init__(parent)
        self.changeToOther("Anat Filename",
                """
The name of the anatomical image, e.g. myfile, no suffix needed.
Please be sure that the name of anatomical images should be unified for each
subject, e.g. myfile.nii.gz. If there are multiple anatomical images for each
subject, the name of the image should be myfile1.nii.gz, myfile2.nii.gz etc.
                """
                )
        self.setFixedWidth(120)
        self.Ety.setMinimumWidth(80)

    def editValue(self):
        value=checkValue(self.value, self.Ety, "s")
        if not value is None:
            Str=QString(str(value))
            if Str.isEmpty():
                self.value=None
            else:
                self.value=value
                self.emit(SIGNAL("update(QString)"), Str)

class ScansNum(ValueBox):
    def __init__(self, parent=None):
        super(ScansNum, self).__init__(parent)
        self.changeToOther("Scans Number",
                "The number of anatomical images")
        self.setFixedWidth(100)
        self.setFrameStyle(QFrame.StyledPanel|QFrame.Raised)

    def editValue(self):
        value=checkValue(self.value, self.Ety, "i")
        if not value is None:
            Str=QString(str(value))
            if Str.isEmpty():
                self.value=None
            else:
                self.value=value
                self.emit(SIGNAL("update(QString)"), Str)

class GPUBox(CheckBox):
    def __init__(self, parent=None):
        super(GPUBox, self).__init__(parent)

        self.changeToOther("Use GPU",
                """
Use GPU to compute
                """
                )
        self.setFrameStyle(QFrame.StyledPanel|QFrame.Raised)

class GCutBox(CheckBox):
    def __init__(self, parent=None):
        super(GCutBox, self).__init__(parent)
        self.changeToOther("Freesufer \"Gcut\" Option",
                """
If Gcut is selected, the edges of gray matter and cerebellum
will be aggressive cutting in the skull stripping process
                """
                )
        self.setFrameStyle(QFrame.StyledPanel|QFrame.Raised)

class DenoisedBox(CheckBox):
    def __init__(self, parent=None):
        super(DenoisedBox, self).__init__(parent)
        self.changeToOther("Denoised",
                """
Denoise Images
                """
                )
        self.setFrameStyle(QFrame.StyledPanel|QFrame.Raised)

class HeadBox(QFrame):
    def __init__(self, parent=None):
        super(HeadBox, self).__init__(parent)

        Lab=QLabel("Head Template")
        Lab.setFixedWidth(150)
        fileBox=FileBox()
        fileBox.setToolTip(
            """
The head template which the individual anatomical images register to, 
eg. MNI152_T1_2mm.nii.gz
            """
            )
        self.connect(fileBox, SIGNAL("update(QString)"),
                self, SIGNAL("update(QString)"))

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)
        mainLayout.addWidget(Lab)
        mainLayout.addWidget(fileBox)

        self.Lab=Lab
        self.fileBox=fileBox

    def setEnabled(self, state):
        state=bool(state)
        flag=not state
        self.fileBox.setDisabled(flag)

    def getFile(self):
        File=self.fileBox.getFile()
        return File

    def setFile(self, File):
        self.fileBox.setFile(File)

    def changeToOther(self, 
            title, tooltipPush):
        self.Lab.setText(title)
        self.fileBox.setToolTip(tooltipPush)

    def setFixedWidth(self, width):
        self.Lab.setFixedWidth(width)

class BrainBox(HeadBox):
    def __init__(self, parent=None):
        super(BrainBox, self).__init__(parent)

        self.changeToOther("Brain Template",
                """
The brain template which the individual anatomical images register to, 
e.g. MNI152_T1_2mm_brain.nii.gz
                """
                )
        self.setFixedWidth(150)

class TPatternBox(QFrame):
    def __init__(self, parent=None):
        super(TPatternBox, self).__init__(parent)

        Lab=QLabel("TPattern")
        Combo=QComboBox()
        Combo.addItem("alt+z")
        Combo.addItem("alt-z")
        Combo.addItem("seq+z")
        Combo.addItem("seq-z")

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)
        mainLayout.addWidget(Lab)
        mainLayout.addWidget(Combo)

        self.connect(Combo, 
                SIGNAL("currentIndexChanged(int)"),
                self.changeTPattern)

        self.Lab=Lab
        self.Combo=Combo
        self.item="alt+z"

    def changeTPattern(self, index):
        item=self.Combo.itemText(index)
        self.item=item
        self.emit(SIGNAL("update(QString)"), item)

    def getItem(self):
        item=self.item
        return item

    def setItem(self, item):
        if item=='alt+z':
            self.Combo.setCurrentIndex(0)
            value=0
        elif item=='alt-z':
            self.Combo.setCurrentIndex(1)
            value=1
        elif item=='seq+z':
            self.Combo.setCurrentIndex(2)
            value=2
        elif item=='seq-z':
            self.Combo.setCurrentIndex(3)
            value=3
        self.item=item
        self.emit(SIGNAL("currentIndexChanged(int)"),
                value)

    def changeToOther(self, title, tooltip):
        self.Lab.setText(title)
        self.Combo.setToolTip(tooltip)
    
    def setFixedWidth(self, width):
        self.Lab.setFixedWidth(width)

class SurfaceBox(TPatternBox):
    def __init__(self, parent=None):
        super(SurfaceBox, self).__init__(parent)

        self.changeToOther("Surface Template",
                """
The surface template is the surface registration target from FreeSurfer,
e.g. fsaverage5
                """
                )
        self.setFixedWidth(150)
        self.Combo.clear()
        self.Combo.addItem("fsaverage3")
        self.Combo.addItem("fsaverage4")
        self.Combo.addItem("fsaverage5")
        self.Combo.addItem("fsaverage6")
        self.Combo.setCurrentIndex(2)
        self.item="fsaverage5"

    def setItem(self, item):
        if item=='fsaverage3':
            self.Combo.setCurrentIndex(0)
            value=0
        elif item=='fsaverage4':
            self.Combo.setCurrentIndex(1)
            value=1
        elif item=='fsaverage5':
            self.Combo.setCurrentIndex(2)
            value=2
        elif item=='fsaverage6':
            self.Combo.setCurrentIndex(3)
            value=3
        self.item=item
        self.emit(SIGNAL("currentIndexChanged(int)"),
                value)

class RefineBox(FCBox):
    def __init__(self, parent=None):
        super(RefineBox, self).__init__(parent)
        self.changeToOther("Refine Template",
                """
Execute Refine
                """,
                """
Set Refine Template
                """
                )
        self.setFixedWidth(150)

class FuncDir(ValueBox):
    def __init__(self, parent=None):
        super(FuncDir, self).__init__(parent)
        self.changeToOther("Func Directory",
                """
The name of directory where the resting state images are put in.
                """
                )
        self.setFixedWidth(120)
        self.Ety.setMinimumWidth(80)

    def editValue(self):
        value=checkValue(self.value, self.Ety, "s")
        if not value is None:
            Str=QString(str(value))
            if Str.isEmpty():
                self.value=None
            else:
                self.value=value
                self.emit(SIGNAL("update(QString)"), Str)

class FuncFile(ValueBox):
    def __init__(self, parent=None):
        super(FuncFile, self).__init__(parent)
        self.changeToOther("Func Filename",
                """
The name of the functional images,
e.g. rest, no suffix needed.
                """
                )
        self.setFixedWidth(120)
        self.Ety.setMinimumWidth(80)

    def editValue(self):
        value=checkValue(self.value, self.Ety, "s")
        if not value is None:
            Str=QString(str(value))
            if Str.isEmpty():
                self.value=None
            else:
                self.value=value
                self.emit(SIGNAL("update(QString)"), Str)

class EPIBox(HeadBox):
    def __init__(self, parent=None):
        super(EPIBox, self).__init__(parent)

        self.changeToOther("Func Template",
                """
The template which the individual functional images register to,
e.g. MNI152_T1_3mm_brain.nii.gz.
                """
                )
        self.setFixedWidth(150)

class TRBox(ValueBox):
    def __init__(self, parent=None):
        super(TRBox, self).__init__(parent)
        self.changeToOther("TR",
                "Repetition time")
        self.setFrameStyle(QFrame.StyledPanel|QFrame.Raised)

class DropNum(ValueBox):
    def __init__(self, parent=None):
        super(DropNum, self).__init__(parent)
        self.changeToOther("Dropped Volumes",
                """
The first several of initial fMRI volumes will be deleted 
to grant the signal equilibrium.
                """
                )
        self.setFrameStyle(QFrame.StyledPanel|QFrame.Raised)

    def editValue(self):
        value=checkValue(self.value, self.Ety, "i")
        if not value is None:
            Str=QString(str(value))
            if Str.isEmpty():
                self.value=None
            else:
                self.value=value
                self.emit(SIGNAL("update(QString)"), Str)


class PreConfig(QWidget):
    def __init__(self, parent=None):
        super(PreConfig, self).__init__(parent)

        mainLayout=QVBoxLayout(self)
        mainLayout.setMargin(8)
        mainLayout.setSpacing(5)

        anatDir=AnatDir()
        anatFile=AnatFile()

        snumBox=ScansNum()
        gcutBox=GCutBox()
        gpuBox=GPUBox()
        dnBox=DenoisedBox()
        dnBox.setDisabled(True)

        headBox=HeadBox()
        brainBox=BrainBox()
        surfaceBox=SurfaceBox()
        refineBox=RefineBox()
        
        group=Group(direction=QBoxLayout.TopToBottom)
        group.setTitle("Anatomical Process")

        HBox=QHBoxLayout()
        HBox.setMargin(0)
        HBox.setSpacing(0)

        Frame=FrameLayout(direction=QBoxLayout.TopToBottom)
        Frame.setFrameStyle(QFrame.StyledPanel|QFrame.Raised)
        Frame.addChildWidget(anatDir)
        Frame.addChildWidget(anatFile)
        HBox.addWidget(Frame)
        HBox.setStretchFactor(Frame, 1)

        VBox=QVBoxLayout()
        VBox.setMargin(0)
        VBox.setSpacing(0)
        VBox.addWidget(snumBox)
        VBox.addWidget(gcutBox)
        HBox.addLayout(VBox)

        VBox=QVBoxLayout()
        VBox.setMargin(0)
        VBox.setSpacing(0)
        VBox.addWidget(dnBox)
        VBox.addWidget(gpuBox)
        HBox.addLayout(VBox)

        group.addChildLayout(HBox)

        Frame=FrameLayout(direction=QBoxLayout.TopToBottom)
        Frame.setFrameStyle(QFrame.StyledPanel|QFrame.Sunken)
        Frame.addChildWidget(headBox)
        Frame.addChildWidget(brainBox)
        Frame.addChildWidget(refineBox)

        group.addChildWidget(Frame)
        mainLayout.addWidget(group)

        funcDir=FuncDir()
        funcFile=FuncFile()

        trBox=TRBox()
        tpBox=TPatternBox()
        tpBox.setFrameStyle(QFrame.StyledPanel|QFrame.Raised)

        dnumBox=DropNum()
        bandBox=BandBox()
        bandBox.setFrameStyle(QFrame.StyledPanel|QFrame.Raised)

        funcBox=EPIBox()

        group=Group(direction=QBoxLayout.TopToBottom)
        group.setTitle("Functional Process")

        HBox=QHBoxLayout()
        HBox.setMargin(0)
        HBox.setSpacing(0)

        Frame=FrameLayout(direction=QBoxLayout.TopToBottom)
        Frame.setFrameStyle(QFrame.StyledPanel|QFrame.Raised)
        Frame.addChildWidget(funcDir)
        Frame.addChildWidget(funcFile)
        HBox.addWidget(Frame)

        VBox=QVBoxLayout()
        VBox.setMargin(0)
        VBox.setSpacing(0)
        VBox.addWidget(trBox)
        VBox.addWidget(tpBox)
        HBox.addLayout(VBox)

        VBox=QVBoxLayout()
        VBox.setMargin(0)
        VBox.setSpacing(0)
        VBox.addWidget(dnumBox)
        VBox.addWidget(bandBox)
        HBox.addLayout(VBox)

        Frame=FrameLayout(direction=QBoxLayout.TopToBottom)
        Frame.setFrameStyle(QFrame.StyledPanel|QFrame.Sunken)
        Frame.addChildWidget(surfaceBox)
        Frame.addChildWidget(funcBox)

        group.addChildLayout(HBox)
        group.addChildWidget(Frame)

        mainLayout.addWidget(group)

        #Skull Strip Para
        self.connect(anatDir, SIGNAL("update(QString)"),
                self, SIGNAL("updateAnatDir(QString)"))
        self.connect(anatFile, SIGNAL("update(QString)"),
                self, SIGNAL("updateAnatFile(QString)"))
        self.connect(snumBox, SIGNAL("update(QString)"),
                self, SIGNAL("updateScansNum(QString)"))
        self.connect(gcutBox, SIGNAL("update(bool)"),
                self, SIGNAL("updateGcut(bool)"))
        self.connect(dnBox, SIGNAL("update(bool)"),
                self, SIGNAL("updateDenoised(bool)"))

        #Anat Process Para
        self.connect(gpuBox, 
                SIGNAL("update(bool)"),
                self, 
                SIGNAL("updateGPU(bool)"))
        self.connect(headBox, 
                SIGNAL("update(QString)"),
                self,
                SIGNAL("updateHead(QString)"))
        self.connect(brainBox, 
                SIGNAL("update(QString)"),
                self, 
                SIGNAL("updateBrain(QString)"))
        self.connect(refineBox,
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateIsRefine(bool)"))
        self.connect(refineBox,
                SIGNAL("updateFile(QString)"),
                self,
                SIGNAL("updateRefine(QString)"))

        #Func Process Para
        self.connect(funcDir, SIGNAL("update(QString)"),
                self, SIGNAL("updateFuncDir(QString)"))
        self.connect(funcFile, SIGNAL("update(QString)"),
                self, SIGNAL("updateFuncFile(QString)"))
        self.connect(trBox, SIGNAL("update(QString)"),
                self, SIGNAL("updateTR(QString)"))
        self.connect(dnumBox, SIGNAL("update(QString)"),
                self, SIGNAL("updateDropNum(QString)"))
        self.connect(tpBox, SIGNAL("update(QString)"),
                self, SIGNAL("updateTPattern(QString)"))
        self.connect(bandBox, 
                SIGNAL("updateLow(QString)"),
                self, SIGNAL("updateBandLow(QString)"))
        self.connect(bandBox,
                SIGNAL("updateHigh(QString)"),
                self, SIGNAL("updateBandHigh(QString)"))
        self.connect(funcBox, SIGNAL("update(QString)"),
                self, SIGNAL("updateFunc(QString)"))
        self.connect(surfaceBox, 
                SIGNAL("update(QString)"),
                self,
                SIGNAL("updateSurface(QString)"))

        self.anatDir=anatDir
        self.anatFile=anatFile
        self.snumBox=snumBox
        self.gpuBox=gpuBox
        self.gcutBox=gcutBox
        self.dnBox=dnBox

        self.headBox=headBox
        self.brainBox=brainBox
        self.surfaceBox=surfaceBox
        self.refineBox=refineBox

        self.funcDir=funcDir
        self.funcFile=funcFile
        self.trBox=trBox
        self.tpBox=tpBox
        self.dnumBox=dnumBox
        self.bandBox=bandBox

        self.funcBox=funcBox

    def save(self, fp):
        anat_dir=self.anatDir.getValue()
        anat_file=self.anatFile.getValue()
        s_num=self.snumBox.getValue()
        gpu=self.gpuBox.getState()
        g_cut=self.gcutBox.getState()
        denoised=self.dnBox.getState()

        head=self.headBox.getFile()
        brain=self.brainBox.getFile()
        surface=self.surfaceBox.getItem()
        useRefine=self.refineBox.getState()
        refine=self.refineBox.getFile()

        func_dir=self.funcDir.getValue()
        func_file=self.funcFile.getValue()
        tr=self.trBox.getValue()
        tp=self.tpBox.getItem()
        d_num=self.dnumBox.getValue()
        low=self.bandBox.getLow()
        high=self.bandBox.getHigh()

        func=self.funcBox.getFile()

        config=ConfigParser()
        config.add_section("Anatomical Directory")
        config.set("Anatomical Directory",
                "Name", anat_dir)
        config.add_section("Anatomical Filename")
        config.set("Anatomical Filename",
                "Name", anat_file)
        config.add_section("Scans Number")
        config.set("Scans Number",
                "Number", s_num)
        config.add_section("FreeSurfer-GCut")
        config.set("FreeSurfer-GCut",
                "Execute", g_cut)
        config.add_section("GPU")
        config.set("GPU",
                "Execute", gpu)
        config.add_section("Denoised")
        config.set("Denoised",
                "Execute", denoised)

        config.add_section("Anatomical Template")
        config.set("Anatomical Template",
                "Head", head)
        config.set("Anatomical Template",
                "Brain", brain)
        config.set("Anatomical Template",
                "Surface", surface)

        config.add_section("Refine Template")
        config.set("Refine Template",
                "Execute", useRefine)
        config.set("Refine Template",
                "Template", refine)

        config.add_section("Functional Directory")
        config.set("Functional Directory",
                "Name", func_dir)
        config.add_section("Functional Filename")
        config.set("Functional Filename",
                "Name", func_file)
        config.add_section("TR")
        config.set("TR", "Value", tr)
        config.add_section("Dropped Volumes")
        config.set("Dropped Volumes",
                "Number", d_num)
        config.add_section("TPattern")
        config.set("TPattern",
                "Item", tp)
        config.add_section("Band")
        config.set("Band",
                "Low_cut-off", low)
        config.set("Band",
                "High_cut-off", high)
        config.add_section("Functional Template")
        config.set("Functional Template",
                "Template", func)

        config.write(fp)

    def load(self, fp):
        config=ConfigParser()
        config.readfp(fp)

        anat_dir=config.get("Anatomical Directory",
                "Name")
        if anat_dir=='None':
            anat_dir=None
        anat_file=config.get("Anatomical Filename",
                "Name")
        if anat_file=='None':
            anat_file=None
        try: 
            s_num=config.getint("Scans Number",
                    "Number")
        except:
            s_num=None
        gpu=config.getboolean("GPU",
                "Execute")
        g_cut=config.getboolean("FreeSurfer-GCut",
                "Execute")
        denoised=config.getboolean("Denoised",
                "Execute")
        head=config.get("Anatomical Template",
                "Head")
        if head=='None':
            head=None
        brain=config.get("Anatomical Template",
                "Brain")
        if brain=='None':
            brain=None
        surface=config.get("Anatomical Template",
                "Surface")
        useRefine=config.getboolean("Refine Template",
                "Execute")
        refine=config.get("Refine Template",
                "Template")
        if refine=='None':
            refine=None

        func_dir=config.get("Functional Directory",
                "Name")
        if func_dir=='None':
            func_dir=None
        func_file=config.get("Functional Filename",
                "Name")
        if func_file=='None':
            func_file=None

        try:
            tr=config.getfloat("TR", "value")
        except:
            tr=None

        try:
            d_num=config.getint("Dropped Volumes",
                    "Number")
        except:
            d_num=None

        tp=config.get("TPattern", "Item")

        try:
            low=config.getfloat("Band", "Low_cut-off")
        except:
            low=None

        try:
            high=config.getfloat("Band", "High_cut-off")
        except:
            high=None

        func=config.get("Functional Template",
                "Template")
        if func=='None':
            func=None

        self.anatDir.setValue(anat_dir)
        self.anatFile.setValue(anat_file)
        self.snumBox.setValue(s_num)
        self.gpuBox.setState(gpu)
        self.gcutBox.setState(g_cut)
        self.dnBox.setState(denoised)
        self.headBox.setFile(head)
        self.brainBox.setFile(brain)
        self.surfaceBox.setItem(surface)
        self.refineBox.setState(useRefine)
        self.refineBox.setFile(refine)
        
        self.funcDir.setValue(func_dir)
        self.funcFile.setValue(func_file)
        self.trBox.setValue(tr)
        self.tpBox.setItem(tp)
        self.dnumBox.setValue(d_num)
        self.bandBox.setLow(low)
        self.bandBox.setHigh(high)
        self.funcBox.setFile(func)

    def default(self):
        self.anatDir.setValue("anat")
        self.anatFile.setValue("mprage")
        self.snumBox.setValue(1)
        self.gpuBox.setState(False)
        self.gcutBox.setState(False)
        self.dnBox.setState(False)

        FSLDIR=os.getenv("FSLDIR")
        head=os.path.join(FSLDIR, "data", "standard",\
                "MNI152_T1_2mm.nii.gz")
        brain=os.path.join(FSLDIR, "data", "standard",\
                "MNI152_T1_2mm_brain.nii.gz")
        self.headBox.setFile(head)
        self.brainBox.setFile(brain)
        self.surfaceBox.setItem("fsaverage5")
        self.refineBox.setState(False)
        self.refineBox.setFile(None)
        
        self.funcDir.setValue("func")
        self.funcFile.setValue("rest")
        self.trBox.setValue(3.0)
        self.tpBox.setItem("alt+z")
        self.dnumBox.setValue(5)
        self.bandBox.setLow(0.01)
        self.bandBox.setHigh(0.1)

        CCSDIR=os.getenv("CCSDIR")
        func=os.path.join(CCSDIR, "bin", "templates",\
                "MNI152_T1_3mm_brain.nii.gz")
        self.funcBox.setFile(func)

if __name__=='__main__':
    app=QApplication(sys.argv)
    main=PreConfig()
    main.show()
    app.exec_()
