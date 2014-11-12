from PyQt4.QtGui import *
from PyQt4.QtCore import *
from ccsBase import *
from ConfigParser import *
import sys, os


#class VolumeBaseBox(CheckBox):
#    def __init__(self, parent=None):
#        super(VolumeBaseBox, self).__init__(parent)
#        self.changeToOther("Volume-based (3D)",
#                """
#Volume-based
#                """
#                )
#class SurfaceBaseBox(CheckBox):
#    def __init__(self, parent=None):
#        super(SurfaceBaseBox, self).__init__(parent)
#        self.changeToOther("Surface-based (2D)",
#                """
#Surface-based
#                """
#                )

class VolumeBox(CheckBox):
    def __init__(self, parent=None):
        super(VolumeBox, self).__init__(parent)

        self.setLabText("Volume-based ( 3D )")
        self.setLabToolTip(
                """
Volume-based ( 3D )
                """)

class SurfaceBox(CheckBox):
    def __init__(self, parent=None):
        super(SurfaceBox, self).__init__(parent)

        self.setLabText("Surface-based ( 2D )")
        self.setLabToolTip(
                """
Surface-based ( 2D )
                """)

class ALFFBox(CheckBox):
    def __init__(self, parent=None):
        super(ALFFBox, self).__init__(parent)

        self.setLabText(
                """
ALFF (0.01 - 0.1) / fALFF (0.01 - 0.1) / Slow 4)
                """
                )
        self.setLabToolTip(
                """
Amplitude of Low Frequency Fluctuation (ALFF): 
ALFF is calculated as the sum of amplitudes within a 
specific low frequency band (e.g. 0.01-0.1Hz). 
It represents the strength or variability of low frequency
oscillation.

Fractional Amplitude of Low Frequency Fluctuation (fALFF): 
fALFF is calculated as the ALFF of given frequency band
divided the sum of amplitudes across the entire frequency
range detectable in a given signal.
It represents the relative contribution of specific low
frequency oscillation to the whole detectable frequency
range.
                """
                )

class ReHoBox(CheckBox):
    def __init__(self, parent=None):
        super(ReHoBox, self).__init__(parent)

        self.setLabText("ReHo")
        self.setLabToolTip(
                """
Regional Homogeneity (ReHo):
ReHo is an index to measure the locally functional homogeneity
of a region.
It is calculated by Kendall's coefficient of concordance (KCC)
of resting state time series between each voxel and its 26
neighbors.
                """)

class VMHCBox(ReHoBox):
    def __init__(self, parent=None):
        super(VMHCBox, self).__init__(parent)

        self.setLabText("VMHC")
        self.setLabToolTip(
                """
Voxel-mirrored homotopic connectivity (VMHC):
VMHC is the resting state functional connectivity between
each voxel in one hemisphere and its mirrored counterpart
in the order.
                """
                )

#class ALFFBox(QWidget):
#    def __init__(self, parent=None):
#        super(ALFFBox, self).__init__(parent)
#        checkBtn=QCheckBox("ALFF  /  fALFF  /  Slow4")
#        checkBtn.setToolTip(
#                """
#Amplitude of Low Frequency Fluctuation (ALFF): 
#ALFF is calculated as the sum of amplitudes within a specific 
#low frequency band (e.g. 0.01-0.1Hz). 
#It represents the strength or variability of low frequency
#oscillation.
#
#Fractional Amplitude of Low Frequency Fluctuation (fALFF): 
#fALFF is calculated as the ALFF of given frequency band divided
#the sum of amplitudes across the entire frequency range
#detectable in a given signal.
#It represents the relative contribution of specific low
#frequency oscillation to the whole detectable frequency range.
#                """
#                )
#        bandBox=BandBox()
#        bandBox.setDisabled(True)
#        bandBox.setFrameStyle(
#                QFrame.StyledPanel|QFrame.Sunken)
#
#        mainLayout=QHBoxLayout(self)
#        mainLayout.setMargin(5)
#        mainLayout.setSpacing(2)
#        mainLayout.setAlignment(Qt.AlignLeft)
#        mainLayout.addWidget(checkBtn)
#        mainLayout.addWidget(bandBox)
#
#        self.connect(checkBtn, SIGNAL("stateChanged(int)"),
#                self.setEnabled)
#        self.connect(bandBox, SIGNAL("updateLow(QString)"),
#                self, SIGNAL("updateLow(QString)"))
#        self.connect(bandBox, SIGNAL("updateHigh(QString)"),
#                self, SIGNAL("updateHigh(QString)"))
#
#        self.checkBtn=checkBtn
#        self.bandBox=bandBox
#
#    def getState(self):
#        state=self.checkBtn.isChecked()
#        return state
#
#    def setState(self, state):
#        self.checkBtn.setChecked(state)
#
#    def setEnabled(self, state):
#        state=bool(state)
#        self.emit(SIGNAL("updateState(bool)"), state)
#        flag=not state
#        self.bandBox.setDisabled(flag)
#
#    def getBand(self):
#        low=self.bandBox.getLow()
#        high=self.bandBox.getHigh()
#        return low, high
#
#    def setBand(self, low, high):
#        self.bandBox.setLow(low)
#        self.bandBox.setHigh(high)
#
#    def changeToOther(self, title, tooltip):
#        self.checkBtn.setText(title)
#        self.checkBtn.setToolTip(tooltip)

#class fALFFBox(ALFFBox):
#    def __init__(self, parent=None):
#        super(fALFFBox, self).__init__(parent)
#        self.changeToOther("fALFF",
#                """
#Fractional Amplitude of Low Frequency Fluctuation (fALFF): 
#fALFF is calculated as the ALFF of given frequency band divided
#the sum of amplitudes across the entire frequency range
#detectable in a given signal.
#It represents the relative contribution of specific low
#frequency oscillation to the whole detectable frequency range.
#                """
#                )

class VNCMBox(QFrame):
    def __init__(self, parent=None):
        super(VNCMBox, self).__init__(parent)

        DCBtn=QCheckBox("DC")
        DCBtn.setToolTip(
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
        ECBtn=QCheckBox("EC")
        ECBtn.setToolTip(
                """
Eigenvector Centrality (EC):
EC is the largest eigenvector of the adjacency matrix.
It is able to capture an aspect of centrality that extends to
global features of the graph.
                """
                )
        BCBtn=QCheckBox("BC")
        BCBtn.setToolTip(
                """
Betweenness Centrality (BC):
BC is an index to measure the load and importance of a node. 
It is the number/weight of shortest paths from all voxel to all
others that pass through the node.
                """
                )
        PCBtn=QCheckBox("PC")
        PCBtn.setToolTip(
                """
Page-rank centrality (PC):
PC is a variant of eigenvector centrality calculated by Google
page-rank centrality algorithm.
                """
                )

        PValueBox=ValueBox()
        PValueBox.setDisabled(True)
        PValueBox.changeToOther(
                "p value ( DC / EC / BC / PC )",
                "Set p value")
        PValueBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Sunken)

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)

        HBox=QHBoxLayout()
        HBox.setMargin(0)
        HBox.setSpacing(0)
        HBox.addWidget(DCBtn)
        HBox.addWidget(ECBtn)
        HBox.addWidget(BCBtn)
        HBox.addWidget(PCBtn)

        mainLayout.addLayout(HBox)
        mainLayout.addWidget(PValueBox)
        mainLayout.setStretchFactor(HBox, 1)

        self.connect(DCBtn, SIGNAL("stateChanged(int)"),
                self.updateDCState)
        self.connect(ECBtn, SIGNAL("stateChanged(int)"),
                self.updateECState)
        self.connect(BCBtn, SIGNAL("stateChanged(int)"),
                self.updateBCState)
        self.connect(PCBtn, SIGNAL("stateChanged(int)"),
                self.updatePCState)
        self.connect(PValueBox, 
                SIGNAL("update(QString)"),
                self, SIGNAL("updatePValue(QString)"))

        self.DCBtn=DCBtn
        self.ECBtn=ECBtn
        self.BCBtn=BCBtn
        self.PCBtn=PCBtn
        self.PValueBox=PValueBox

    def updateDCState(self, state):
        self.checkPValueDisabled()
        state=bool(state)
        self.emit(SIGNAL("updateDCState(bool)"), state)

    def updateECState(self, state):
        self.checkPValueDisabled()
        state=bool(state)
        self.emit(SIGNAL("updateECState(bool)"), state)

    def updateBCState(self, state):
        self.checkPValueDisabled()
        state=bool(state)
        self.emit(SIGNAL("updateBCState(bool)"), state)

    def updatePCState(self, state):
        self.checkPValueDisabled()
        state=bool(state)
        self.emit(SIGNAL("updatePCState(bool)"), state)

    def getDCState(self):
        state=self.DCBtn.isChecked()
        return state

    def getECState(self):
        state=self.ECBtn.isChecked()
        return state

    def getBCState(self):
        state=self.BCBtn.isChecked()
        return state

    def getPCState(self):
        state=self.PCBtn.isChecked()
        return state

    def getPValue(self):
        value=self.PValueBox.getValue()
        return value

    def setDCState(self, state):
        self.DCBtn.setChecked(state)

    def setECState(self, state):
        self.ECBtn.setChecked(state)

    def setBCState(self, state):
        self.BCBtn.setChecked(state)

    def setPCState(self, state):
        self.PCBtn.setChecked(state)

    def setPValue(self, value):
        self.PValueBox.setValue(value)

    def setPValueDisabled(self, nonstate):
        self.PValueBox.setDisabled(nonstate)

    def checkPValueDisabled(self):
        DCState=self.getDCState()
        ECState=self.getECState()
        BCState=self.getBCState()
        PCState=self.getPCState()

        PValueState=DCState or ECState \
                or BCState or PCState
        self.setPValueDisabled(not PValueState)

    def setDisabled(self, nonstate):
        self.DCBtn.setDisabled(nonstate)
        self.ECBtn.setDisabled(nonstate)
        self.BCBtn.setDisabled(nonstate)
        self.PCBtn.setDisabled(nonstate)

        self.setPValueDisabled(True)
        self.setPValue(None)

        self.setDCState(False)
        self.setECState(False)
        self.setBCState(False)
        self.setPCState(False)

class VolumeFCBox(FileBoxCombo):
    def __init__(self, parent=None):
        super(VolumeFCBox, self).__init__(parent)
        
        self.setLabText("FC")
        self.setLabToolTip(
                """
Voxel-wise Functional Connectivity (FC):
Please set a seed mask in MNI152 space. The resolution 
of the seed mask should be as the same as the resolution
of function image.
                """
                )
        self.ListFile=None

    def updateList(self):
        ListFile=self.ListFile
        if ListFile is None:
            self.emit(SIGNAL("updateListFile(QString)"),
                    QString())
            return

        fp=open(ListFile)
        text=fp.read()
        fp.close()
        lines=text.splitlines()
        lines=QStringList(lines)
        lines.removeDuplicates()
        ROIList=QStringList()
        for line in lines:
            if line.isEmpty():
                continue
            ROIList.append(line)

        self.Combo.clear()
        self.Combo.addItems(ROIList)

        self.emit(SIGNAL("updateList(QStringList)"),
                ROIList)
        self.emit(SIGNAL("updateListFile(QString)"),
                ListFile)
        self.Files=ROIList

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
        self.Combo.addItems(Files)

        self.emit(SIGNAL("updateList(QStringList)"), 
                Files)

        HomeDir=os.getenv("HOME")
        HomeInfo=QDir(HomeDir)
        HomeCCSDir=os.path.join(HomeDir, ".ccs")
        HomeCCSInfo=QDir(HomeCCSDir)

        if not HomeCCSInfo.exists():
            HomeInfo.mkdir(".ccs")

        ListFile=os.path.join(HomeCCSDir, "ROIList.list")
        fp=open(ListFile, "w")
        fp.write(Files.join("\n"))
        fp.close()
        self.emit(SIGNAL("updateListFile(QString)"), 
                ListFile)

        self.Files=Files
        self.ListFile=ListFile

    def getListFile(self):
        ListFile=self.ListFile
        return ListFile

    def setListFile(self, ListFile):
        self.ListFile=ListFile
        self.updateList()

class SurfaceFCBox(FileBoxCombo):
    def __init__(self, parent=None):
        super(SurfaceFCBox, self).__init__(parent)
        
        self.setLabText("FC")
        self.setLabToolTip(
                """
Vortex-wise Functional Connectivity (FC):
Please set a seed mask in MNI152 space. The resolution 
of the seed mask should be as the same as the resolution
of function image.
                """
                )
        self.ListFile=None

    def updateList(self):
        ListFile=self.ListFile
        if ListFile is None:
            self.emit(
                    SIGNAL("updateRegion(QStringList)"),
                    QStringList())
            self.emit(
                    SIGNAL("updateRL(QStringList)"),
                    QStringList())
            self.emit(SIGNAL("updateListFile(QString)"),
                    QString())
            return
        RegionList=QStringList()
        RLList=QStringList()
        self.Combo.clear()

        fp=open(ListFile)
        text=fp.read()
        fp.close()
        lines=text.splitlines()
        for s in lines:
            if QString(s).isEmpty():
                continue

            try:
                region, rl=s.split(",")
            except:
                QMessageBox.critical(self, "Input Error",
                        self.tr("Invalid CSV File"))
            
            RegionList.append(QString(region))
            RLList.append(QString(rl))
            item="%s ( %s )" % (region, rl)
            self.Combo.addItem(item)
        self.emit(SIGNAL("updateRegion(QStringList)"),
                RegionList)
        self.emit(SIGNAL("updateRL(QStringList)"),
                RLList)
        self.emit(SIGNAL("updateListFile(QString)"),
                ListFile)
        self.RegionList=RegionList
        self.RLList=RLList

    def openFiles(self):
        ListFile=self.ListFile
        if ListFile is None:
            Dir=QDir.currentPath()
        else:
            Info=QFileInfo(ListFile)
            Dir=Info.absoluteFilePath()
         
        ListFile=QFileDialog.getOpenFileName(self,
                self.tr("Select Region List"),
                Dir,
                self.tr("Region List { *.csv } "+
                    "(*.csv);;"+
                    "All Files { *.* } (*.* *)")
                )
        if ListFile.isEmpty():
            return
        self.ListFile=ListFile
        self.updateList()

    def getRegionList(self):
        List=self.RegionList
        return List

    def getRLList(self):
        List=self.RLList
        return List

    def getListFile(self):
        ListFile=self.ListFile
        return ListFile

    def setListFile(self, ListFile):
        self.ListFile=ListFile
        self.updateList()

class VolumeFrame(QFrame):
    def __init__(self, parent=None):
        super(VolumeFrame, self).__init__(parent)

        self.setFrameStyle(
                QFrame.StyledPanel|QFrame.Plain)

        volumeBox=VolumeBox()
        #ReHo
        rehoBox=ReHoBox()
        rehoBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)
        rehoBox.setDisabled(True)
        #ALFF / fALFF / Slow4
        alffBox=ALFFBox()
        alffBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)
        alffBox.setDisabled(True)
        #VMHC
        vmhcBox=VMHCBox()
        vmhcBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)
        vmhcBox.setDisabled(True)
        #VNCM ( DC EC BC PC ) 
        vncmBox=VNCMBox()
        vncmBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)
        vncmBox.setDisabled(True)
        #FC
        fcBox=VolumeFCBox()
        fcBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)
        fcBox.setDisabled(True)

        mainLayout=QVBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)

        mainLayout.addWidget(volumeBox)

        Frame=FrameLayout(None, QBoxLayout.TopToBottom)
        Frame.setFrameStyle(
                QFrame.StyledPanel|QFrame.Sunken)
        
        HBox=QHBoxLayout()
        HBox.setMargin(0)
        HBox.setSpacing(0)
        HBox.addWidget(alffBox)
        HBox.addWidget(rehoBox)
        HBox.addWidget(vmhcBox)

        Frame.addChildLayout(HBox)
        Frame.addChildWidget(vncmBox)
        Frame.addChildWidget(fcBox)

        mainLayout.addWidget(Frame)
        mainLayout.setStretchFactor(Frame, 1)

        self.connect(volumeBox, 
                SIGNAL("updateState(bool)"),
                self.updateState)
        self.connect(volumeBox,
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateVolState(bool)"))

        self.connect(rehoBox,
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateReHoState(bool)"))
        self.connect(alffBox,
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateALFFState(bool)"))
        self.connect(vmhcBox,
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateVMHCState(bool)"))
        self.connect(vncmBox,
                SIGNAL("updateDCState(bool)"),
                self,
                SIGNAL("updateDCState(bool)"))
        self.connect(vncmBox,
                SIGNAL("updateECState(bool)"),
                self,
                SIGNAL("updateECState(bool)"))
        self.connect(vncmBox,
                SIGNAL("updateBCState(bool)"),
                self,
                SIGNAL("updateBCState(bool)"))
        self.connect(vncmBox,
                SIGNAL("updatePCState(bool)"),
                self,
                SIGNAL("updatePCState(bool)"))
        self.connect(vncmBox,
                SIGNAL("updatePValue(QString)"),
                self,
                SIGNAL("updateVNCMPValue(QString)"))
        self.connect(fcBox,
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateFCState(bool)"))
        self.connect(fcBox,
                SIGNAL("updateList(QStringList)"),
                self,
                SIGNAL("updateFCROI(QStringList)"))
        self.connect(fcBox,
                SIGNAL("updateListFile(QString)"),
                self,
                SIGNAL("updateFCListFile(QString)"))

        self.volumeBox=volumeBox

        self.rehoBox=rehoBox
        self.alffBox=alffBox
        self.vmhcBox=vmhcBox
        self.vncmBox=vncmBox
        self.fcBox=fcBox

    def updateState(self, state):
        nonstate=not state

        self.rehoBox.setDisabled(nonstate)
        self.alffBox.setDisabled(nonstate)
        self.vmhcBox.setDisabled(nonstate)
        self.vncmBox.setDisabled(nonstate)
        self.fcBox.setDisabled(nonstate)

    def getVolState(self):
        state=self.volumeBox.getState()
        return state
    
    def getReHoState(self):
        state=self.rehoBox.getState()
        return state

    def getALFFState(self):
        state=self.alffBox.getState()
        return state

    def getVMHCState(self):
        state=self.vmhcBox.getState()
        return state

    def getDCState(self):
        state=self.vncmBox.getDCState()
        return state

    def getECState(self):
        state=self.vncmBox.getECState()
        return state

    def getBCState(self):
        state=self.vncmBox.getBCState()
        return state

    def getPCState(self):
        state=self.vncmBox.getPCState()
        return state

    def getPValue(self):
        value=self.vncmBox.getPValue()
        return value

    def getFCState(self):
        state=self.fcBox.getState()
        return state

    def getFCFiles(self):
        Files=self.fcBox.getFiles()
        return Files

    def getFCListFile(self):
        ListFile=self.fcBox.getListFile()
        return ListFile

    def setVolState(self, state):
        self.volumeBox.setState(state)

    def setReHoState(self, state):
        self.rehoBox.setState(state)

    def setALFFState(self, state):
        self.alffBox.setState(state)

    def setVMHCState(self, state):
        self.vmhcBox.setState(state)

    def setDCState(self, state):
        self.vncmBox.setDCState(state)

    def setECState(self, state):
        self.vncmBox.setECState(state)

    def setBCState(self, state):
        self.vncmBox.setBCState(state)

    def setPCState(self, state):
        self.vncmBox.setPCState(state)

    def setPValue(self, value):
        self.vncmBox.setPValue(value)

    def setFCState(self, state):
        self.fcBox.setState(state)

    def setFCFiles(self, Files):
        self.fcBox.setFiles(Files)

    def setFCListFile(self, ListFile):
        self.fcBox.setListFile(ListFile)

class SurfaceFrame(QFrame):
    def __init__(self, parent=None):
        super(SurfaceFrame, self).__init__(parent)

        self.setFrameStyle(
                QFrame.StyledPanel|QFrame.Plain)

        surfaceBox=SurfaceBox()
        #ReHo
        rehoBox=ReHoBox()
        rehoBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)
        rehoBox.setDisabled(True)
        #ALFF / fALFF / Slow4
        alffBox=ALFFBox()
        alffBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)
        alffBox.setDisabled(True)
        #VMHC
        vmhcBox=VMHCBox()
        vmhcBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)
        vmhcBox.setDisabled(True)
        #VNCM ( DC EC BC PC ) 
        vncmBox=VNCMBox()
        vncmBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)
        vncmBox.setDisabled(True)
        #FC
        fcBox=SurfaceFCBox()
        fcBox.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)
        fcBox.setDisabled(True)

        mainLayout=QVBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)

        mainLayout.addWidget(surfaceBox)

        Frame=FrameLayout(None, QBoxLayout.TopToBottom)
        Frame.setFrameStyle(
                QFrame.StyledPanel|QFrame.Sunken)
        
        HBox=QHBoxLayout()
        HBox.setMargin(0)
        HBox.setSpacing(0)
        HBox.addWidget(alffBox)
        HBox.addWidget(rehoBox)
        HBox.addWidget(vmhcBox)

        Frame.addChildLayout(HBox)
        Frame.addChildWidget(vncmBox)
        Frame.addChildWidget(fcBox)

        mainLayout.addWidget(Frame)
        mainLayout.setStretchFactor(Frame, 1)

        self.connect(surfaceBox, 
                SIGNAL("updateState(bool)"),
                self.updateState)
        self.connect(surfaceBox, 
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateSurState(bool)"))

        self.connect(rehoBox,
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateReHoState(bool)"))
        self.connect(alffBox,
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateALFFState(bool)"))
        self.connect(vmhcBox,
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateVMHCState(bool)"))
        self.connect(vncmBox,
                SIGNAL("updateDCState(bool)"),
                self,
                SIGNAL("updateDCState(bool)"))
        self.connect(vncmBox,
                SIGNAL("updateECState(bool)"),
                self,
                SIGNAL("updateECState(bool)"))
        self.connect(vncmBox,
                SIGNAL("updateBCState(bool)"),
                self,
                SIGNAL("updateBCState(bool)"))
        self.connect(vncmBox,
                SIGNAL("updatePCState(bool)"),
                self,
                SIGNAL("updatePCState(bool)"))
        self.connect(vncmBox,
                SIGNAL("updatePValue(QString)"),
                self,
                SIGNAL("updateVNCMPValue(QString)"))
        self.connect(fcBox,
                SIGNAL("updateState(bool)"),
                self,
                SIGNAL("updateFCState(bool)"))
        self.connect(fcBox,
                SIGNAL("updateRegion(QStringList)"),
                self,
                SIGNAL("updateFCRegion(QStringList)"))
        self.connect(fcBox,
                SIGNAL("updateRL(QStringList)"),
                self,
                SIGNAL("updateFCRL(QStringList)"))
        self.connect(fcBox,
                SIGNAL("updateListFile(QString)"),
                self,
                SIGNAL("updateFCListFile(QString)"))

        self.surfaceBox=surfaceBox

        self.rehoBox=rehoBox
        self.alffBox=alffBox
        self.vmhcBox=vmhcBox
        self.vncmBox=vncmBox
        self.fcBox=fcBox

    def updateState(self, state):
        nonstate=not state

        self.rehoBox.setDisabled(nonstate)
        self.alffBox.setDisabled(nonstate)
        self.vmhcBox.setDisabled(nonstate)
        self.vncmBox.setDisabled(nonstate)
        self.fcBox.setDisabled(nonstate)

    def getSurState(self):
        state=self.surfaceBox.getState()
        return state
    
    def getReHoState(self):
        state=self.rehoBox.getState()
        return state

    def getALFFState(self):
        state=self.alffBox.getState()
        return state

    def getVMHCState(self):
        state=self.vmhcBox.getState()
        return state

    def getDCState(self):
        state=self.vncmBox.getDCState()
        return state

    def getECState(self):
        state=self.vncmBox.getECState()
        return state

    def getBCState(self):
        state=self.vncmBox.getBCState()
        return state

    def getPCState(self):
        state=self.vncmBox.getPCState()
        return state

    def getPValue(self):
        value=self.vncmBox.getPValue()
        return value

    def getFCState(self):
        state=self.fcBox.getState()
        return state

    def getFCListFile(self):
        File=self.fcBox.getListFile()
        return File

    def setSurState(self, state):
        self.surfaceBox.setState(state)

    def setReHoState(self, state):
        self.rehoBox.setState(state)

    def setALFFState(self, state):
        self.alffBox.setState(state)

    def setVMHCState(self, state):
        self.vmhcBox.setState(state)

    def setDCState(self, state):
        self.vncmBox.setDCState(state)

    def setECState(self, state):
        self.vncmBox.setECState(state)

    def setBCState(self, state):
        self.vncmBox.setBCState(state)

    def setPCState(self, state):
        self.vncmBox.setPCState(state)

    def setPValue(self, value):
        self.vncmBox.setPValue(value)

    def setFCState(self, state):
        self.fcBox.setState(state)

    def setFCListFile(self, File):
        self.fcBox.setListFile(File)

#class ECBox(DCBox):
#    def __init__(self, parent=None):
#        super(ECBox, self).__init__(parent)
#        self.changeToOther("EC",
#                """
#Eigenvector Centrality (EC):
#EC is the largest eigenvector of the adjacency matrix.
#It is able to capture an aspect of centrality that extends to
#global features of the graph.
#                """
#                )
#
#class BCBox(DCBox):
#    def __init__(self, parent=None):
#        super(BCBox, self).__init__(parent)
#        self.changeToOther("BC",
#                """
#Betweenness Centrality (BC):
#BC is an index to measure the load and importance of a node. 
#It is the number/weight of shortest paths from all voxel to all
#others that pass through the node.
#                """
#                )
#
#class PCBox(DCBox):
#    def __init__(self, parent=None):
#        super(PCBox, self).__init__(parent)
#        self.changeToOther("PC",
#                """
#Page-rank centrality (PC):
#PC is a variant of eigenvector centrality calculated by Google
#page-rank centrality algorithm.
#                """
#                )

#class VMHCBox(FCBox):
#    def __init__(self, parent=None):
#        super(VMHCBox, self).__init__(parent)
#        self.changeToOther("VMHC",
#                """
#Voxel-mirrored homotopic connectivity (VMHC):
#VMHC is the resting state functional connectivity between each
#voxel in one hemisphere and its mirrored counterpart in the
#order.
#                """,
#                "Set VMHC Seed Mask")
#        self.setFixedWidth(80)

#class VSBox(QFrame):
#    def __init__(self, parent=None):
#        super(VSBox, self).__init__(parent) 
#        self.setFrameStyle(
#                QFrame.StyledPanel|QFrame.Sunken)
#
#        volumeBox=VolumeBaseBox()
#        surfaceBox=SurfaceBaseBox()
#        
#        mainLayout=QHBoxLayout(self)
#        mainLayout.setMargin(0)
#        mainLayout.setSpacing(0)
#        mainLayout.addWidget(volumeBox)
#        mainLayout.addWidget(surfaceBox)
#
#        self.connect(volumeBox, SIGNAL("update(bool)"),
#                self, SIGNAL("updateVol(bool)"))
#        self.connect(surfaceBox, SIGNAL("update(bool)"),
#                self, SIGNAL("updateSur(bool)"))
#
#        self.volumeBox=volumeBox
#        self.surfaceBox=surfaceBox
#
#    def getVol(self):
#        vol=self.volumeBox.getState()
#        return vol
#    
#    def getSur(self):
#        sur=self.surfaceBox.getState()
#        return sur
#
#    def setVol(self, vol):
#        self.volumeBox.setState(vol)
#    
#    def setSur(self, sur):
#        self.surfaceBox.setState(sur)

class PostConfig(QWidget):
    def __init__(self, parent=None):
        super(PostConfig, self).__init__(parent)

        volumeFrame=VolumeFrame()
        surfaceFrame=SurfaceFrame()

        group=Group(direction=QBoxLayout.TopToBottom)
        group.setTitle("Post-process")

        group.addChildWidget(volumeFrame)
        group.addChildWidget(surfaceFrame)

        mainLayout=QHBoxLayout(self)
        mainLayout.setMargin(8)
        mainLayout.setSpacing(5)
        mainLayout.addWidget(group)

        #Volume
        self.connect(volumeFrame,
                SIGNAL("updateVolState(bool)"),
                self,
                SIGNAL("updateVolState(bool)"))
        self.connect(volumeFrame,
                SIGNAL("updateReHoState(bool)"),
                self,
                SIGNAL("updateVolReHoState(bool)"))
        self.connect(volumeFrame,
                SIGNAL("updateALFFState(bool)"),
                self,
                SIGNAL("updateVolALFFState(bool)"))
        self.connect(volumeFrame,
                SIGNAL("updateVMHCState(bool)"),
                self,
                SIGNAL("updateVolVMHCState(bool)"))
        self.connect(volumeFrame,
                SIGNAL("updateVMHCState(bool)"),
                self,
                SIGNAL("updateVolVMHCState(bool)"))
        self.connect(volumeFrame,
                SIGNAL("updateDCState(bool)"),
                self,
                SIGNAL("updateVolDCState(bool)"))
        self.connect(volumeFrame,
                SIGNAL("updateECState(bool)"),
                self,
                SIGNAL("updateVolECState(bool)"))
        self.connect(volumeFrame,
                SIGNAL("updateBCState(bool)"),
                self,
                SIGNAL("updateVolBCState(bool)"))
        self.connect(volumeFrame,
                SIGNAL("updatePCState(bool)"),
                self,
                SIGNAL("updateVolPCState(bool)"))
        self.connect(volumeFrame,
                SIGNAL("updateVNCMPValue(QString)"),
                self,
                SIGNAL("updateVolVNCMPValue(QString)"))
        self.connect(volumeFrame,
                SIGNAL("updateFCState(bool)"),
                self,
                SIGNAL("updateVolFCState(bool)"))
        self.connect(volumeFrame,
                SIGNAL("updateFCROI(QStringList)"),
                self,
                SIGNAL("updateVolFCROI(QStringList)"))
        self.connect(volumeFrame,
                SIGNAL("updateFCListFile(QString)"),
                self,
                SIGNAL("updateVolFCListFile(QString)"))

        #Surface
        self.connect(surfaceFrame,
                SIGNAL("updateSurState(bool)"),
                self,
                SIGNAL("updateSurState(bool)"))
        self.connect(surfaceFrame,
                SIGNAL("updateReHoState(bool)"),
                self,
                SIGNAL("updateSurReHoState(bool)"))
        self.connect(surfaceFrame,
                SIGNAL("updateALFFState(bool)"),
                self,
                SIGNAL("updateSurALFFState(bool)"))
        self.connect(surfaceFrame,
                SIGNAL("updateVMHCState(bool)"),
                self,
                SIGNAL("updateSurVMHCState(bool)"))
        self.connect(surfaceFrame,
                SIGNAL("updateVMHCState(bool)"),
                self,
                SIGNAL("updateSurVMHCState(bool)"))
        self.connect(surfaceFrame,
                SIGNAL("updateDCState(bool)"),
                self,
                SIGNAL("updateSurDCState(bool)"))
        self.connect(surfaceFrame,
                SIGNAL("updateECState(bool)"),
                self,
                SIGNAL("updateSurECState(bool)"))
        self.connect(surfaceFrame,
                SIGNAL("updateBCState(bool)"),
                self,
                SIGNAL("updateSurBCState(bool)"))
        self.connect(surfaceFrame,
                SIGNAL("updatePCState(bool)"),
                self,
                SIGNAL("updateSurPCState(bool)"))
        self.connect(surfaceFrame,
                SIGNAL("updateVNCMPValue(QString)"),
                self,
                SIGNAL("updateSurVNCMPValue(QString)"))
        self.connect(surfaceFrame,
                SIGNAL("updateFCState(bool)"),
                self,
                SIGNAL("updateSurFCState(bool)"))
        self.connect(surfaceFrame,
                SIGNAL("updateFCRegion(QStringList)"),
                self,
                SIGNAL("updateSurFCRegion(QStringList)"))
        self.connect(surfaceFrame,
                SIGNAL("updateFCRL(QStringList)"),
                self,
                SIGNAL("updateSurFCRL(QStringList)"))
        self.connect(surfaceFrame,
                SIGNAL("updateFCListFile(QString)"),
                self,
                SIGNAL("updateSurFCListFile(QString)"))

        self.volumeFrame=volumeFrame
        self.surfaceFrame=surfaceFrame
    
    def save(self, fp):
        useVol=self.volumeFrame.getVolState()
        useVolALFF=self.volumeFrame.getALFFState()
        useVolReHo=self.volumeFrame.getReHoState()
        useVolVMHC=self.volumeFrame.getVMHCState()
        useVolDC=self.volumeFrame.getDCState()
        useVolEC=self.volumeFrame.getECState()
        useVolBC=self.volumeFrame.getBCState()
        useVolPC=self.volumeFrame.getPCState()
        VolVNCM_P=self.volumeFrame.getPValue()
        useVolFC=self.volumeFrame.getFCState()
        VolFCListFile=self.volumeFrame.getFCListFile()
        
        useSur=self.surfaceFrame.getSurState()
        useSurALFF=self.surfaceFrame.getALFFState()
        useSurReHo=self.surfaceFrame.getReHoState()
        useSurVMHC=self.surfaceFrame.getVMHCState()
        useSurDC=self.surfaceFrame.getDCState()
        useSurEC=self.surfaceFrame.getECState()
        useSurBC=self.surfaceFrame.getBCState()
        useSurPC=self.surfaceFrame.getPCState()
        SurVNCM_P=self.surfaceFrame.getPValue()
        useSurFC=self.surfaceFrame.getFCState()
        SurFCListFile=self.surfaceFrame.getFCListFile()

        config=ConfigParser()
        config.add_section("Volume")
        config.set("Volume", "Execute", useVol)
        config.set("Volume", "ALFF", useVolALFF)
        config.set("Volume", "ReHo", useVolReHo)
        config.set("Volume", "VMHC", useVolVMHC)
        config.set("Volume", "VNCM_DC", useVolDC)
        config.set("Volume", "VNCM_EC", useVolEC)
        config.set("Volume", "VNCM_BC", useVolBC)
        config.set("Volume", "VNCM_PC", useVolPC)
        config.set("Volume", "VNCM_PValue", VolVNCM_P)
        config.set("Volume", "FC", useVolFC)
        config.set("Volume",
                "FC_ListFile", VolFCListFile)

        config.add_section("Surface")
        config.set("Surface", "Execute", useSur)
        config.set("Surface", "ALFF", useSurALFF)
        config.set("Surface", "ReHo", useSurReHo)
        config.set("Surface", "VMHC", useSurVMHC)
        config.set("Surface", "VNCM_DC", useSurDC)
        config.set("Surface", "VNCM_EC", useSurEC)
        config.set("Surface", "VNCM_BC", useSurBC)
        config.set("Surface", "VNCM_PC", useSurPC)
        config.set("Surface", "VNCM_PValue", SurVNCM_P)
        config.set("Surface", "FC", useSurFC)
        config.set("Surface",
                "FC_ListFile", SurFCListFile)

        config.write(fp)

    def load(self, fp):
        config=ConfigParser()
        config.readfp(fp)

        useVol=config.getboolean("Volume", "Execute")
        useVolALFF=config.getboolean("Volume", "ALFF")
        useVolReHo=config.getboolean("Volume", "ReHo")
        useVolVMHC=config.getboolean("Volume", "VMHC")
        useVolDC=config.getboolean("Volume", "VNCM_DC")
        useVolEC=config.getboolean("Volume", "VNCM_EC")
        useVolBC=config.getboolean("Volume", "VNCM_BC")
        useVolPC=config.getboolean("Volume", "VNCM_PC")
        try:
            VolVNCM_P=config.getfloat("Volume",
                    "VNCM_PValue")
        except:
            VolVNCM_P=None
        useVolFC=config.getboolean("Volume", "FC")
        VolFCListFile=config.get("Volume",
                "FC_ListFile")
        if VolFCListFile=='None':
            VolFCListFile=None

        useSur=config.getboolean("Surface", "Execute")
        useSurALFF=config.getboolean("Surface", "ALFF")
        useSurReHo=config.getboolean("Surface", "ReHo")
        useSurVMHC=config.getboolean("Surface", "VMHC")
        useSurDC=config.getboolean("Surface", "VNCM_DC")
        useSurEC=config.getboolean("Surface", "VNCM_EC")
        useSurBC=config.getboolean("Surface", "VNCM_BC")
        useSurPC=config.getboolean("Surface", "VNCM_PC")
        try:
            SurVNCM_P=config.getfloat("Surface",
                    "VNCM_PValue")
        except:
            SurVNCM_P=None
        useSurFC=config.getboolean("Surface", "FC")
        SurFCListFile=config.get("Surface",
                "FC_ListFile")
        if SurFCListFile=='None':
            SurFCListFile=None

        self.volumeFrame.setVolState(useVol)

        self.volumeFrame.setALFFState(useVolALFF)
        self.volumeFrame.setReHoState(useVolReHo)
        self.volumeFrame.setVMHCState(useVolVMHC)
        self.volumeFrame.setDCState(useVolDC)
        self.volumeFrame.setECState(useVolEC)
        self.volumeFrame.setBCState(useVolBC)
        self.volumeFrame.setPCState(useVolPC)
        self.volumeFrame.setPValue(VolVNCM_P)
        self.volumeFrame.setFCState(useVolFC)
        self.volumeFrame.setFCListFile(VolFCListFile)

        self.surfaceFrame.setSurState(useSur)

        self.surfaceFrame.setALFFState(useSurALFF)
        self.surfaceFrame.setReHoState(useSurReHo)
        self.surfaceFrame.setVMHCState(useSurVMHC)
        self.surfaceFrame.setDCState(useSurDC)
        self.surfaceFrame.setECState(useSurEC)
        self.surfaceFrame.setBCState(useSurBC)
        self.surfaceFrame.setPCState(useSurPC)
        self.surfaceFrame.setPValue(SurVNCM_P)
        self.surfaceFrame.setFCState(useSurFC)
        self.surfaceFrame.setFCListFile(SurFCListFile)

    def default(self):
        self.volumeFrame.setVolState(True)

        self.volumeFrame.setALFFState(True)
        self.volumeFrame.setReHoState(True)
        self.volumeFrame.setVMHCState(True)
        self.volumeFrame.setDCState(True)
        self.volumeFrame.setECState(True)
        self.volumeFrame.setBCState(True)
        self.volumeFrame.setPCState(True)
        self.volumeFrame.setPValue(0.05)
        self.volumeFrame.setFCState(False)
        self.volumeFrame.setFCListFile(None)

        self.surfaceFrame.setSurState(True)

        self.surfaceFrame.setALFFState(True)
        self.surfaceFrame.setReHoState(True)
        self.surfaceFrame.setVMHCState(True)
        self.surfaceFrame.setDCState(True)
        self.surfaceFrame.setECState(True)
        self.surfaceFrame.setBCState(True)
        self.surfaceFrame.setPCState(True)
        self.surfaceFrame.setPValue(0.05)
        self.surfaceFrame.setFCState(False)
        self.surfaceFrame.setFCListFile(None)

#class PostConfig(QWidget):
#    def __init__(self, parent=None):
#        super(PostConfig, self).__init__(parent)
#
#        rehoBox=ReHoBox()
#        #vsBox=VSBox()
#
#        alffBox=ALFFBox()
#        #falffBox=fALFFBox()
#
#        #dcBox=DCBox()
#        #ecBox=ECBox()
#        #bcBox=BCBox()
#        #pcBox=PCBox()
#
#        fcBox=FCBox()
#        vmhcBox=VMHCBox()
#
#        group=Group(direction=QBoxLayout.TopToBottom)
#        group.setTitle("Post-process")
#
#        HBox=QHBoxLayout()
#        HBox.setMargin(0)
#        HBox.setSpacing(0)
#        #HBox.addWidget(vsBox)
#        HBox.addWidget(rehoBox)
#        group.addChildLayout(HBox)
#
#        Frame=FrameLayout()
#        Frame.setFrameStyle(
#                QFrame.StyledPanel|QFrame.Raised)
#        Frame.addChildWidget(alffBox)
#        #Frame.addChildWidget(falffBox)
#        group.addChildWidget(Frame)
#
#        Frame=FrameLayout()
#        Frame.setFrameStyle(
#                QFrame.StyledPanel|QFrame.Raised)
#        #Frame.addChildWidget(dcBox)
#        #Frame.addChildWidget(ecBox)
#        #Frame.addChildWidget(bcBox)
#        #Frame.addChildWidget(pcBox)
#        group.addChildWidget(Frame)
#
#        VBox=QVBoxLayout()
#        VBox.setMargin(0)
#        VBox.setSpacing(0)
#        VBox.addWidget(fcBox)
#        VBox.addWidget(vmhcBox)
#        Frame=FrameLayout()
#        Frame.setFrameStyle(
#                QFrame.StyledPanel|QFrame.Raised)
#        Frame.addChildLayout(VBox)
#        group.addChildWidget(Frame)
#
#        mainLayout=QHBoxLayout(self)
#        mainLayout.setMargin(8)
#        mainLayout.setSpacing(5)
#        mainLayout.addWidget(group)
#
#        #Volume and Surface
#        #self.connect(vsBox, SIGNAL("updateVol(bool)"),
#        #        self, SIGNAL("updateVolState(bool)"))
#        #self.connect(vsBox, SIGNAL("updateSur(bool)"),
#        #        self, SIGNAL("updateSurState(bool)"))
#
#        #ReHo
#        self.connect(rehoBox, SIGNAL("updateState(bool)"),
#                self, SIGNAL("updateReHoState(bool)"))
#
#        #ALFF
#        self.connect(alffBox, SIGNAL("updateState(bool)"),
#                self, SIGNAL("updateALFFState(bool)"))
#        self.connect(alffBox, SIGNAL("updateLow(QString)"),
#                self, SIGNAL("updateALFFLow(QString)"))
#        self.connect(alffBox, SIGNAL("updateHigh(QString)"),
#               self, SIGNAL("updateALFFHigh(QString)"))
#
#        #fALFF
#        #self.connect(falffBox, SIGNAL("updateState(bool)"),
#        #        self, SIGNAL("updatefALFFState(bool)"))
#        #self.connect(falffBox, SIGNAL("updateLow(QString)"),
#        #        self, SIGNAL("updatefALFFLow(QString)"))
#        #self.connect(falffBox, SIGNAL("updateHigh(QString)"),
#        #        self, SIGNAL("updatefALFFHigh(QString)"))
#
#        #DC
#        #self.connect(dcBox, SIGNAL("updateState(bool)"),
#        #        self, SIGNAL("updateDCState(bool)"))
#        #self.connect(dcBox, SIGNAL("updateP(QString)"),
#        #        self, SIGNAL("updateDCP(QString)"))
#
#        #EC
#        #self.connect(ecBox, SIGNAL("updateState(bool)"),
#        #        self, SIGNAL("updateECState(bool)"))
#        #self.connect(ecBox, SIGNAL("updateP(QString)"),
#        #        self, SIGNAL("updateECP(QString)"))
#
#        #BC
#        #self.connect(bcBox, SIGNAL("updateState(bool)"),
#        #        self, SIGNAL("updateBCState(bool)"))
#        #self.connect(bcBox, SIGNAL("updateP(QString)"),
#        #        self, SIGNAL("updateBCP(QString)"))
#
#        #PC
#        #self.connect(pcBox, SIGNAL("updateState(bool)"),
#        #        self, SIGNAL("updatePCState(bool)"))
#        #self.connect(pcBox, SIGNAL("updateP(QString)"),
#        #        self, SIGNAL("updatePCP(QString)"))
#        #FC
#        self.connect(fcBox, SIGNAL("updateState(bool)"),
#                self, SIGNAL("updateFCState(bool)"))
#        self.connect(fcBox, SIGNAL("updateFile(QString)"),
#                self, SIGNAL("updateFCFile(QString)"))
#
#        #VMHC
#        self.connect(vmhcBox, SIGNAL("updateState(bool)"),
#                self, SIGNAL("updateVMHCState(bool)"))
#        self.connect(vmhcBox, SIGNAL("updateFile(QString)"),
#                self, SIGNAL("updateVMHCFile(QString)"))
#
#        self.rehoBox=rehoBox
#        #self.vsBox=vsBox
#        self.alffBox=alffBox
#        #self.falffBox=falffBox
#        #self.dcBox=dcBox
#        #self.ecBox=ecBox
#        #self.bcBox=bcBox
#        #self.pcBox=pcBox
#        self.fcBox=fcBox
#        self.vmhcBox=vmhcBox
#
#    def save(self, fp):
#        useReHo=self.rehoBox.getState()
#        vol=self.vsBox.getVol()
#        sur=self.vsBox.getSur()
#        
#        useALFF=self.alffBox.getState()
#        lowALFF, highALFF=self.alffBox.getBand()
#
#        #usefALFF=self.falffBox.getState()
#        #lowfALFF, highfALFF=self.falffBox.getBand()
#        
#        useDC=self.dcBox.getState()
#        pDC=self.dcBox.getValue()
#
#        useEC=self.ecBox.getState()
#        pEC=self.ecBox.getValue()
#
#        useBC=self.bcBox.getState()
#        pBC=self.bcBox.getValue()
#
#        usePC=self.pcBox.getState()
#        pPC=self.pcBox.getValue()
#
#        useFC=self.fcBox.getState()
#        fileFC=self.fcBox.getFile()
#
#        useVMHC=self.vmhcBox.getState()
#        fileVMHC=self.vmhcBox.getFile()
#
#        config=ConfigParser()
#        config.add_section("Mode")
#        config.set("Mode", "Volume", vol)
#        config.set("Mode", "Surface", sur)
#
#        config.add_section("ReHo")
#        config.set("ReHo", "Execute", useReHo)
#
#        config.add_section("ALFF/fALFF")
#        config.set("ALFF/fALFF", "Execute", useALFF)
#        config.set("ALFF/fALFF", "Low_cut-off", lowALFF)
#        config.set("ALFF/fALFF", "High_cut-off", highALFF)
#
#        #config.add_section("fALFF")
#        #config.set("fALFF", "Execute", usefALFF)
#        #config.set("fALFF", "Low_cut-off", lowfALFF)
#        #config.set("fALFF", "High_cut-off", highfALFF)
#        
#        config.add_section("DC")
#        config.set("DC", "Execute", useDC)
#        config.set("DC", "P_value", pDC)
#
#        config.add_section("EC")
#        config.set("EC", "Execute", useEC)
#        config.set("EC", "P_value", pEC)
#
#        config.add_section("BC")
#        config.set("BC", "Execute", useBC)
#        config.set("BC", "P_value", pBC)
#
#        config.add_section("PC")
#        config.set("PC", "Execute", usePC)
#        config.set("PC", "P_value", pPC)
#
#        config.add_section("FC")
#        config.set("FC", "Execute", useFC)
#        config.set("FC", "Mask", fileFC)
#
#        config.add_section("VMHC")
#        config.set("VMHC", "Execute", useVMHC)
#        config.set("VMHC", "Mask", fileVMHC)
#
#        config.write(fp)
#
#    def load(self, fp):
#        config=ConfigParser()
#        config.readfp(fp)
#
#        vol=config.getboolean("Mode", "Volume")
#        sur=config.getboolean("Mode", "Surface")
#
#        useReHo=config.getboolean("ReHo", "Execute")
#
#        useALFF=config.getboolean("ALFF/fALFF", "Execute")
#        try:
#            lowALFF=config.getfloat("ALFF/fALFF", "Low_cut-off")
#        except:
#            lowALFF=None
#        try:
#            highALFF=config.getfloat("ALFF/fALFF", "High_cut-off")
#        except:
#            highALFF=None
#
#        #usefALFF=config.getboolean("fALFF", "Execute")
#        #try:
#        #    lowfALFF=config.getfloat("fALFF", "Low_cut-off")
#        #except:
#        #    lowfALFF=None
#        #try:
#        #    highfALFF=config.getfloat("fALFF", "High_cut-off")
#        #except:
#        #    highfALFF=None
#        
#        useDC=config.getboolean("DC", "Execute")
#        try:
#            pDC=config.getfloat("DC", "P_value")
#        except:
#            pDC=None
#
#        useEC=config.getboolean("EC", "Execute")
#        try:
#            pEC=config.getfloat("EC", "P_value")
#        except:
#            pEC=None
#
#        useBC=config.getboolean("BC", "Execute")
#        try:
#            pBC=config.getfloat("BC", "P_value")
#        except:
#            pBC=None
#
#        usePC=config.getboolean("PC", "Execute")
#        try:
#            pPC=config.getfloat("PC", "P_value")
#        except:
#            pPC=None
#
#        useFC=config.getboolean("FC", "Execute")
#        fileFC=config.get("FC", "Mask")
#        if fileFC=='None':
#            fileFC=None
#
#        useVMHC=config.getboolean("VMHC", "Execute")
#        fileVMHC=config.get("VMHC", "Mask")
#        if fileVMHC=='None':
#            fileVMHC=None
#
#        self.vsBox.setVol(vol)
#        self.vsBox.setSur(sur)
#
#        self.rehoBox.setState(useReHo)
#
#        self.alffBox.setState(useALFF)
#        self.alffBox.setBand(lowALFF, highALFF)
#
#        #self.falffBox.setState(usefALFF)
#        #self.falffBox.setBand(lowfALFF, highfALFF)
#
#        self.dcBox.setState(useDC)
#        self.dcBox.setValue(pDC)
#
#        self.ecBox.setState(useEC)
#        self.ecBox.setValue(pEC)
#
#        self.bcBox.setState(useBC)
#        self.bcBox.setValue(pBC)
#
#        self.pcBox.setState(usePC)
#        self.pcBox.setValue(pPC)
#
#        self.fcBox.setState(useFC)
#        self.fcBox.setFile(fileFC)
#
#        self.vmhcBox.setState(useVMHC)
#        self.vmhcBox.setFile(fileVMHC)
#    
#    def default(self):
#        self.rehoBox.setState(True)
#        self.vsBox.setVol(True)
#        self.vsBox.setSur(True)
#
#        self.alffBox.setState(True)
#        self.alffBox.setBand(0.01, 0.08)
#
#        #self.falffBox.setState(True)
#        #self.falffBox.setBand(0.01, 0.08)
#
#        self.dcBox.setState(True)
#        self.dcBox.setValue(0.05)
#
#        self.ecBox.setState(True)
#        self.ecBox.setValue(0.05)
#
#        self.bcBox.setState(True)
#        self.bcBox.setValue(0.05)
#
#        self.pcBox.setState(True)
#        self.pcBox.setValue(0.05)
#
#        self.fcBox.setState(True)
#        self.fcBox.setFile(None)
#
#        self.vmhcBox.setState(True)
#        self.vmhcBox.setFile(None)

if __name__=='__main__':
    app=QApplication(sys.argv)
    main=SurfaceFrame()
    main.show()

    app.exec_()
