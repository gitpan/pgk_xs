package pgk;

# log stubs voor de log server om te gebruiken in perl
# Alleen de client functies

use strict;
use vars qw($VERSION);
$VERSION='0.05';

################################################################

use pgk_xs;

my %events;

sub callBack {
    no strict 'refs';
    my $name=shift;
    my $function=shift;
    &$function(@{$events{$name}{$function}});
}

package pgk::Widget;

sub new {
  my $class=shift;
  my $name=shift;
  my $type=shift;
  my $this;

  $this->{"name"}=$name;
  $this->{"type"}=$type;
  
  $this->{"widgets"}=();
  
  bless $this,$class;

$this;
}

sub add {
    my $this=shift;
    
    while (my $widget=shift) {
    
      push @{$this->{"widgets"}}, $widget;
      $this->setWidget($widget);

     #print $this->getHandle," , ",$widget->getHandle;
     pgk_xs::pgk_add_widget($this->getHandle(),$widget->getHandle());
     #print " --> ok\n";
    }
$this;  
}

sub setHandle {
    my $this=shift;
    my $widget=shift;
    
    $this->{"handle"}=$widget;
}

sub getHandle {
    my $this=shift;
return $this->{"handle"};
}

sub setEvent {
    my $this=shift;
    my $eventFunc=shift;
    my $eventType=shift;
    
    $events{$this->{"handle"}}{$eventFunc}=\@_;
    
    pgk_xs::pgk_set_event($this->getHandle(),$this->{"handle"},$eventFunc,$eventType);
$this;  
}


sub setTimer {
    my $this=shift;
    my $millisecs=shift;
    my $eventFunc=shift;
    
    $events{$this->{"handle"}}{$eventFunc}=\@_;
    
    pgk_xs::pgk_set_timer($millisecs,$this->{"handle"},$eventFunc);
$this;  
}


sub addTimer {
    my $this=shift;
    my $millisecs=shift;
    my $eventFunc=shift;
    
    $this->setTimer($millisecs,$eventFunc,$this,@_);
$this;  
}


sub setProp {
    my $this=shift;
    my $prop=shift;
    if (scalar @_==1) {
        $this->{"prop.$prop"}=shift;
    }
    else {
      $this->{"prop.$prop"}=@_;
    }
}

sub getProp {
    my $this=shift;
    my $prop=shift;
return $this->{"prop.$prop"};
}

sub getWidget {
    my $this=shift;
    my $name=shift;
return $this->{"widget.$name"};
}

sub setWidget {
    my $this=shift;
    my $widget=shift;
    $this->{"widget.".$widget->{"name"}}=$widget;
}

sub show {
  my $this=shift;
  
  pgk_xs::pgk_widget_show_all($this->getHandle);
}

sub setValue {
    my $self=shift;
    my $value=shift;
    
    $self->setProp("Value",$value);
}

sub getValue {
    my $self=shift;
return $self->getProp("Value"); 
}

sub Quit {
    my $self=shift;
    
    pgk_xs::pgk_quit();
}

sub Destroy {
    my $self=shift;

    pgk_xs::pgk_widget_destroy($self->getHandle);
}

sub name {
  my $this=shift;
return $this->{"name"};
}



################################################################

package pgk::App;

use vars qw(@ISA);
@ISA=qw(pgk::Widget);

sub new {
  my $class=shift;
  my $name=shift;
  my $this=$class->SUPER::new($name,"pgk::App");

$this;
}

sub DESTROY {
}

sub Run {
  my $this=shift;
  pgk_xs::pgk_main();
}


################################################################

package pgk::Window;

use vars qw(@ISA);
@ISA=qw(pgk::Widget);

sub new {
    my $class=shift;
    my $name=shift;
    my $title=shift;
    my $args = { 'ALLOW_SHRINK' => 1, 'ALLOW_GROW' => 1, 'AUTO_SHRINK' => 1, 'TYPE' => undef, @_ };

    my $this=$class->SUPER::new($name,"pgk::Window");
    
    $this->{"windowtype"}=$args->{'TYPE'};

    if (not $this->{"windowtype"}) {
        $this->{"windowtype"}=pgk_xs::pgk_window_toplevel();
    }

    $this->setHandle(pgk_xs::pgk_window_new($this->{"windowtype"}));
    $this->setValue($title);

    print $args->{'ALLOW_SHRINK'},",",$args->{'ALLOW_GROW'},",",$args->{'AUTO_SHRINK'},"\n";

        pgk_xs::pgk_window_set_policy($this->getHandle,
                                            $args->{'ALLOW_SHRINK'},
                        $args->{'ALLOW_GROW'},
                        $args->{'AUTO_SHRINK'}
                     );


$this;  
}

sub setValue {
  my $self=shift;
  my $title=shift;
  pgk_xs::pgk_window_set_title($self->getHandle,$title);
  $self->SUPER::setValue($title);
}


################################################################

package pgk::Grid;

use vars qw(@ISA);
@ISA=qw(pgk::Widget);

sub new {
  my $class=shift;
  my $name=shift;
  my $rows=shift;
  my $cols=shift;

     my $this=$class->SUPER::new($name,"pgk::Grid");

     $this->setHandle(pgk_xs::pgk_grid_new($rows,$cols));

$this;
}

################################################################

package pgk::Dialog;

use vars qw(@ISA);
@ISA=qw(pgk::Window);

sub new {
    my $class=shift;
    my $name=shift;
    my $title=shift;
    my $rows=shift;
    my $cols=shift;

        if (not $rows)  { $rows=2; }
        if (not $cols)  { $cols=2; }
        if (not $title) { $title="Dialog has no title"; }

    my $this=$class->SUPER::new($name, $title, 'ALLOW_SHRINK' => 0, 'ALLOW_GROW' => 0 );
    $this->{'dlgGRID'}=new pgk::VBox($name.".grid",$rows,$cols);
    $this->SUPER::add($this->{'dlgGRID'});

$this;  
}

sub add {
   my $this=shift;
    $this->{'dlgGRID'}->add(@_);
$this;
}



################################################################

package pgk::Button;

use vars qw(@ISA);
@ISA=qw(pgk::Widget);

sub new {
    my $class=shift;
    my $name=shift;
    my $text=shift;
    my $command=shift;
    
    my $this=$class->SUPER::new($name,"pgk::Button");
    
    $this->setHandle(pgk_xs::pgk_button_new($text));
    if ($command) { $this->setEvent($command,"clicked",$this,@_); }
}

sub setValue {
    my $this=shift;
    my $label=shift;
    
    pgk_xs::pgk_button_label($this->getHandle(),$label);
}

sub getValue {
    my $this=shift;
    
    return pgk_xs::pgk_button_get_label($this->getHandle());
}


################################################################

package pgk::HBox;

use vars qw(@ISA);
@ISA=qw(pgk::Widget);

sub new {
    my $class=shift;
    my $name=shift;
    
    my $this=$class->SUPER::new($name,"pgk::HBox");
    
    $this->setHandle(pgk_xs::pgk_hbox_new(@_));
$this;  
}

################################################################

package pgk::VBox;

use vars qw(@ISA);
@ISA=qw(pgk::Widget);

sub new {
    my $class=shift;
    my $name=shift;
    
    my $this=$class->SUPER::new($name,"pgk::VBox");
    
    $this->setHandle(pgk_xs::pgk_vbox_new(@_));
$this;  
}

################################################################

package pgk::Text;

use vars qw(@ISA);
@ISA=qw(pgk::Widget);

sub new {
    my $class=shift;
    my $name=shift;
    my $text=shift;
    
    my $this=$class->SUPER::new($name,"pgk::Text");
    
    $this->setHandle(pgk_xs::pgk_text_new($this->getProp("text")));
    
$this;  
}

################################################################

package pgk::Entry;

use vars qw(@ISA);
@ISA=qw(pgk::Widget);

sub new {
    my $class=shift;
    my $name=shift;
    my $text=shift;
    
    my $this=$class->SUPER::new($name,"pgk::Entry");
    
    $this->setHandle(pgk_xs::pgk_entry_new($text,@_));
$this;  
}

sub setValue {
    my $self=shift;
    my $text=shift;
    
    pgk_xs::pgk_entry_set($self->getHandle,$text,@_);
}

sub getValue {
    my $self=shift;
    
    return pgk_xs::pgk_entry_get($self->getHandle);
}


################################################################

package pgk::Label;

use vars qw(@ISA);
@ISA=qw(pgk::Widget);

sub new {
    my $class=shift;
    my $name=shift;
    my $label=shift;
    
    my $this=$class->SUPER::new($name,"pgk::Label");
    $this->setHandle(pgk_xs::pgk_label_new($label,@_));
    
$this;  
}

sub setValue {
    my $this=shift;
    my $label=shift;
    
    pgk_xs::pgk_label_set($this->getHandle(),$label);
}

sub getValue {
    my $this=shift;
    pgk_xs::pgk_label_get($this->getHandle());
}


1;
__END__

=head1 NAME

pgk -- Perl Gimp Kit, a OO perl gtk interface that works for Windows too

=head1 SYNOPSIS

To be done

=head1 DESCRIPTION

=head2 pgk::Widget

=head3 new ($name,$type)

 pre:  $name is the name of this widget.
       $type is the type of this widget.
 post: base class pgk::Widget created, that implements base 
       functions for all derived pgk classes.
          
=head3 add($widget)

 pre:  $widget is a derivative of pgk::Widget.
 post: $widget has been added to the widgetlist of $self.
 
=head3 setHandle($handle)

 pre:  Got $handle from pgk_xs C-function and is a pointer
       to a GTK widget.
 post: $widget is associated with $handle.
 
=head3 $handle=getHandle()

 pre:  setHandle(..)
 post: =the GTK widget pointer associated with this pgk widget.
        Can be used in calls to pgk_xs.
        
=head3 setEvent($eventFunc,$eventType, ...)

 pre:  $eventType <- valid GTK event for the specific GTK Widget
       associated with getHandle()
 post: In case of an event of type $eventType for this GTK Widget,
       $eventFunc will be called with arguments '...'.
 smpl: 
        my $dlg=new pgk::Dialog('my_dialog','This is a title', 3, 3);
        my $lab=new pgk::Label('my_label', 'This is my label');
        $lab->setEvent('main::LabelEvent', 'clicked', $dlg);
        
        In case of a 'clicked' event for the $lab label, main::LabelEvent
        will be called with argument $dlg. E.g., fields in $dlg can be updated.

=head3 setTimer($millisecs,$timerFunc, ...)

 pre:  
 post: Timer is set for $millisecs for this widget. After $millisecs,
       &$timerFunc is called with arguments '...'. 
       Note: timerFunc returns 1 for continues calling.
             timerFunc returns 0 for one shot calling.
 smpl:
       my $dlg=new pgk::Dialog('my_dialog', 'My title', 2, 2);
       $dlg->setTimer(1000, 'main::updateTime', $dlg);
       
       package main;
       
       sub updateTime {
            my $window=shift;
            my $time=ctime();
               $window->setValue($time);
       return 1;
       }

=head3 addTimer($millisecs, $timerFunc, ...)

 pre:
 post: Timer is added to the current widget. After $millisecs,
       &$timerFunc is called with arguments $this, '...'.     
       Note: timerFunc returns 1 for continues calling.
             timerFunc returns 0 for one shot calling.
       
 smpl: my $dlg=new pgk::Dialog('my_dialog', 'My title', 2, 2);
       $dlg->addTimer(1000, 'main::updateTime', "My extra argument");
       
       package main;
       
       sub updateTime {
           my $self=shift;
           my $txt=shift;
           my $time=ctime();
           $self->setValue($time." $txt");
       return 1;    
       }


=head3 setProp($prop,$value|@value)

 post: Property $prop of $widget has been set to $value.
 smpl: $widget->setProp('myprop',"My Value");
 
=head3 getProp($prop)

 post: = value of property $prop of $widget.
 smpl: my $t=$widget->getProp('myprop');
 
=head3 setWidget($widget)

 post: sets property 'widget'.$widget->name() to $widget.
 
=head3 getWidget($name)

 post: =widget of $name, if setWidget has been called before.
       =undef,           otherwise

=head3 setValue($value)

 post: pgk::Widget base class implements this method by calling
       setProp('value',$value).
       
=head3 getValue()

 post: pgk::Widget base class implements this method by calling
       getProp('value').

=head3 show()

 post: shows all PGK widgets associated with the current
       widget, including this one.
      
=head3 Quit()       

 post: Quits the application, destroying all pgk windows opened.
 
=head3 name() 

 post: =name of widget.
 
 

=head1 AUTHOR

H.N.M. Oesterholt-Dijkema <hans@oesterholt-dijkema.emailt.nl>

=head1 LICENSE

perl




