from PyQt4.QtGui import *
from PyQt4.QtCore import *
from ccsBase import *
import sys

QTextCodec.setCodecForTr(QTextCodec.codecForName("utf8"))

class Terminal(QFrame):
    def __init__(self, parent=None):
        super(Terminal, self).__init__(parent)
        self.setFrameStyle(
                QFrame.StyledPanel|QFrame.Raised)

        Text=QTextEdit()
        Text.setReadOnly(True)
        Text.moveCursor(QTextCursor.End)
        Text.setLineWrapMode(QTextEdit.NoWrap)
        
        Process=QProcess(self)
        Process.setProcessChannelMode(
                QProcess.SeparateChannels)

        TermBtn=QPushButton("Terminate")
        TermBtn.setDisabled(True)
        RunBtn=QPushButton("Start")
        HBox=QHBoxLayout()
        HBox.setMargin(0)
        HBox.setSpacing(0)
        HBox.addStretch()
        HBox.addWidget(TermBtn)
        HBox.addWidget(RunBtn)

        mainLayout=QVBoxLayout(self)
        mainLayout.setMargin(5)
        mainLayout.setSpacing(2)
        mainLayout.addWidget(Text)
        mainLayout.addLayout(HBox)

        self.connect(Process, 
                SIGNAL("readyReadStandardOutput()"),
                self.readStdOutput)
        self.connect(Process,
                SIGNAL("readyReadStandardError()"),
                self.readStdError)

        self.connect(Process,
                SIGNAL("finished(int, QProcess::ExitStatus)"), 
                self.finish)
        self.connect(Process,
                SIGNAL("started()"),
                self.init)

        self.connect(TermBtn, SIGNAL("clicked()"),
                self.kill)
        self.connect(RunBtn, SIGNAL("clicked()"),
                self.start)

        self.Text=Text
        self.Process=Process
        self.TermBtn=TermBtn
        self.RunBtn=RunBtn

    def readStdOutput(self):
        mesg=self.tr(self.Process.readAllStandardOutput())
        mesg.replace("\n", "<br>")
        
        self.Text.insertHtml(
                "<font color=\"Black\">"+mesg+"</font>")
        self.Text.moveCursor(QTextCursor.End)

    def readStdError(self):
        mesg=self.tr(self.Process.readAllStandardError())
        mesg.replace("\n", "<br>")
        
        self.Text.insertHtml(
                "<font color=\"Red\">"+mesg+"</font>")
        self.Text.moveCursor(QTextCursor.End)

    def finish(self, exitCode, exitState):
        if exitCode:
            self.Text.insertHtml(
                    "<font color=\"Red\">"+
                    "<br>Error Found!"+"</font>")
        else:
            if exitState:
                self.Text.insertHtml(
                        "<font color=\"Green\">"+
                        "<br>Killed!"+"</font>")
            else:
                self.Text.insertHtml(
                        "<font color=\"Blue\">"+
                        "<br>Finished!"+"</font>")

        self.Text.moveCursor(QTextCursor.End)
        self.TermBtn.setDisabled(True)
        self.RunBtn.setDisabled(False)

    def init(self):
        self.TermBtn.setDisabled(False)
        self.RunBtn.setDisabled(True)
        self.Text.clear()

    def kill(self):
        #self.Process.terminate()
        #os.system("ccs_killall -15 %s" % self.Process.pid())
        os.kill(self.Process.pid(), 19)
        os.kill(self.Process.pid(), 15)
        os.kill(self.Process.pid(), 18)

    def start(self):
        cmd="sh /home/sandy/test.sh"
        self.Process.start(cmd)

if __name__=='__main__':
    app=QApplication(sys.argv)
    main=Terminal()
    main.show()
    app.exec_()
