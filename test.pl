#!/usr/bin/perl

use strict;

use lib "./blib/lib";
use lib "./blib/arch";

use pgk;
use Time::localtime;

my $win32=0;

open IN, "perl --version |";
while (<IN>) {
  if (/win32/i) { $win32=1;last; }
}
close IN;

print "Platform win32=$win32\n";

require Win32::Process if ($win32);

sub doeiets {
    print "args:@_\n";
    my $button=shift;
    my $ctext=shift;
        my $text=$button->getValue;
    
    print "Doet iets! $text\n";
    
    $button->setValue($ctext);
    
        my $dlg=new pgk::Dialog("dialog1","Dit is een dialoog!");
    #my $dlg=new pgk::Window("dialog1","Dit is een dialoog!");
    
    my $ok=new pgk::Button("button2","OK","main::ok");
    my $cancel=new pgk::Button("button3","Cancel","main::cancel",$dlg);
    my $hbox1=new pgk::HBox("hb1");
    my $hbox2=new pgk::HBox("hb2");
    my $label1=new pgk::Label("label11","Enter this:");
    my $label2=new pgk::Label("label22","Enter this:");
    my $entry1=new pgk::Entry("entry2","Fit !");
    my $entry2=new pgk::Entry("entry3","JE");
    
    
    #$dlg->add($cancel,$ok);
    $hbox1->add($label1,$entry1);
    $hbox2->add($label2,$entry2);
    $dlg->add($hbox2);#$dlg->add($hbox2,$cancel,$ok);
    $dlg->add($hbox1);
    $dlg->add($cancel,$ok);
    
    $dlg->show;
}

sub update_time {
    my $this=shift;
        my $window=shift;
    my $time=ctime();
    $this->setValue(ctime());
    $window->setValue(ctime());
return 1;
}


my $process=undef;
my $ProcessObj;

sub ErrorReport{
    print Win32::FormatMessage( Win32::GetLastError() );
}


sub ok {
    print "OK!\n";

    if ($win32) {
    no strict 'subs';
    
        Win32::Process::Create($process,"c:/utils/mp3rec/mp3DirectCut.exe","mp3DirectCut.exe /r",0,NORMAL_PRIORITY_CLASS,".") 
              or die ErrorReport();
    
    }
    
}

sub cancel {
  my $this=shift;
  my $window=shift;
  $window->Destroy;
}

sub quitapp {
  my $this=shift;
  my $window=shift;
  print $this->name()," - ",$window->name(),"\n";
  cancel($this,$window);
  $this->Quit;
}

sub cancelProces {
    my $exitcode;

    if ($win32) {
    
       if ($process) {
        $process->Kill($exitcode);
        print "Process killed, exicode=$exitcode\n";
        $process=undef;
       }
    }
}

my $window=new pgk::Window("main","Test.pl is running!");
my $app=new pgk::App("mainApp");

my $text="text";

my $vbox=new pgk::VBox("vbox1");

my $hbox=new pgk::HBox("hbox1");


my $button=new pgk::Button("button",$text,"main::doeiets","JAJA!");
my $quit=new pgk::Button("quit","Quit","main::quitapp",$window);

print $button->name()," - ",$quit->name(),"\n";

$button->setValue("Test");
#$button->setEvent("main::doeiets","clicked",$button,"JAJA!");
print $button->getHandle(), " - ",$quit->getHandle(),"\n";

my $edit1=new pgk::Text("text","Hallo allemaal");
my $entry1=new pgk::Entry("entry1","Dit is invoer!",0);

my $thetime=new pgk::Label("thetime",ctime());
$thetime->addTimer(1000,"main::update_time",$window);

$window->add($vbox);

$hbox->add($button,$quit,$entry1);
$vbox->add($hbox);
$vbox->add($edit1);
$vbox->add($thetime);

$window->show;

print $app,"\n";
print $window,"\n";

$app->Run();

