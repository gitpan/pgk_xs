#include <gtk/gtk.h>

#include <EXTERN.h>
#include <perl.h>

#ifdef __WIN32__
#undef pipe
#endif

#include <XSUB.h>

static 
void pgk_callback(GtkWidget *widget,gpointer _function) 
{
char  function[512];
char *func,*name;
int  i;

  name=func=function;
  strcpy(function,(char *) _function);
  for(i=0;function[i]!='.' && function[i]!='\0';i++);
  if (function[i]='.') {
      function[i]='\0';
      func=&function[i+1];
  }
  
  {
    dSP;
  
    ENTER;
    SAVETMPS;
  
    PUSHMARK(SP);
  
    XPUSHs(sv_2mortal(newSVpv(name,0)));
    XPUSHs(sv_2mortal(newSVpv(func,0)));
    PUTBACK;
  
    call_pv("pgk::callBack",G_DISCARD);
  
    FREETMPS;
    LEAVE;
  }
}

static gint pgk_timer_callback(gpointer *_function)
{
char  function[512];
char *func,*name;
int   count;
gint  ok;
int  i;

  name=func=function;
  strcpy(function,(char *) _function);
  for(i=0;function[i]!='.' && function[i]!='\0';i++);
  if (function[i]='.') {
      function[i]='\0';
      func=&function[i+1];
  }

  {
      dSP;
  
      ENTER;
      SAVETMPS;
  
      PUSHMARK(SP);
  
      XPUSHs(sv_2mortal(newSVpv(name,0)));
      XPUSHs(sv_2mortal(newSVpv(func,0)));
      PUTBACK;
  
      count=call_pv("pgk::callBack",G_SCALAR);
  
      SPAGAIN;
  
      if (count!=1) {
          croak("Timer function should return 0 (false) to terminate or 1 (true) otherwise\n");
      }
  
      ok=POPi;

      PUTBACK;  
      FREETMPS;
      LEAVE;
  }
  
return ok;  
}


/*
 * Initialisation of GTK.
 */

static 
void init(void)
{
static int init=1;
  if (init) {
    init=0;
    gtk_init(0,NULL);
  }
}

/*
 * Quitting your program.
 */

static
void quit(void) 
{
   gtk_main_quit();
}



/*
 * Get the right justification constant according to input string.
 *  
 * pre:  j==left, right, fill or center
 * post: =GTK_JUSTIFY_LEFT,     j==left
 *       =GTK_JUSTIFY_RIGHT,    j==right
 *       =GTK_JUSTIFY_FILL,     j==fill
 *       =GTK_JUSTIFY_CENTER,   otherwise
 */

static
int _justify(char *j)
{
  if (strcmp(j,"left")==0)       { return GTK_JUSTIFY_LEFT; }
  else if (strcmp(j,"right")==0) { return GTK_JUSTIFY_RIGHT; }
  else if (strcmp(j,"fill")==0)  { return GTK_JUSTIFY_FILL; }
  else                           { return GTK_JUSTIFY_CENTER; }
}


/*
 * Adding widgets to a widget.
 * pre:  widget and add are valid widgets.
 * post: add has been added to the widget container of widget.
 */

static
void add_widget(void *widget, void *add)
{
    gtk_container_add(GTK_CONTAINER((GtkWidget *) widget),(GtkWidget *) add);       
}

/*
 * Starting the XS Module for PERL
 */

MODULE = pgk_xs     PACKAGE = pgk_xs
PROTOTYPES: Enable


void pgk_main()
    CODE:
      gtk_main();



      
void pgk_widget_show(window)
        void *window;
    CODE:
        init();
        gtk_widget_show((GtkWidget *) window);
        
void pgk_widget_show_all(widget)
        void *widget;
    CODE:
        init();
        gtk_widget_show_all((GtkWidget *) widget);

        
void pgk_widget_destroy(widget)
        void *widget;
    CODE:
        init();
        gtk_widget_destroy((GtkWidget *) widget);

                

void pgk_add_widget(widget,add)
        void *widget;
        void *add;
    CODE:
        init();
        add_widget(widget,add);
        

void pgk_set_event(widget,name,function,event)
        void *widget;
        char *name;
        char *function;
        char *event;
    CODE:
        char *func;
        init();
        if (function!=NULL)  {
          func=(char *) malloc(strlen(name)+strlen(function)+1+1);
          sprintf(func,"%s.%s",name,function);
          printf("%s\n",func);
        } 
        else {
          func=NULL;  
        }
        gtk_signal_connect(GTK_OBJECT(widget),event,GTK_SIGNAL_FUNC(pgk_callback),func);
        
        
int pgk_set_timer(millisecs, name, function)
        int   millisecs;
        char *name;
        char *function;
    CODE:
        char *func;
        func=(char *) malloc(strlen(name)+strlen(function)+1+1);
        sprintf(func,"%s.%s",name,function);
        printf("%s\n",func);
        init();
        RETVAL=gtk_timeout_add(millisecs,(GtkFunction) pgk_timer_callback,(gpointer) func);
    OUTPUT:
        RETVAL
        
        
int pgk_window_toplevel()
    CODE:
        init();
        RETVAL=(int) GTK_WINDOW_TOPLEVEL;
    OUTPUT:
        RETVAL    
        

void *pgk_window_new(type)
        int type;
        GtkWindowType t=(GtkWindowType) type;
    CODE:
        init();
        RETVAL=(void *) gtk_window_new(t);
        gtk_signal_connect (GTK_OBJECT (RETVAL), "delete_event", GTK_SIGNAL_FUNC (quit), NULL);
    OUTPUT:
        RETVAL

void pgk_window_set_title(window,label)
        void *window;
        char *label;
    CODE:
        gtk_window_set_title((GtkWindow *) window,label);

void pgk_window_set_policy(window, allow_shrink=1, allow_grow=1,auto_shrink=1 )
        void *window;
        int allow_shrink;
        int allow_grow;
        int auto_shrink;
    CODE:
        gtk_window_set_policy((GtkWindow *) window,allow_shrink,allow_grow,auto_shrink);


void pgk_quit()
    CODE:
        quit();
                
        
                
void *pgk_button_new(label)
        char *label;
    CODE:
        init();
        RETVAL=(void *) gtk_button_new_with_label(label);
    OUTPUT:
        RETVAL
        
        
void pgk_button_label(widget,label)
        void *widget;
        char *label;
    CODE:
        init();
        {
          GtkObject *b=(GtkObject *) widget;
          gtk_object_set(b,"label",label,NULL);
        }
        
        
char *pgk_button_get_label(widget)
        void *widget;
    CODE:
        init();
        {
          const char *s;
          GtkObject *b=(GtkObject *) widget;
          GtkArg     A;
            A.name="label";
            gtk_object_getv(b,1,&A);
            RETVAL=GTK_VALUE_STRING(A);
        }
    OUTPUT:
        RETVAL
    
                
                


void *pgk_dialog_new(modal=1)
        int modal;
    CODE:
        init();
        RETVAL=(void *) gtk_dialog_new();       
        gtk_window_set_modal(GTK_WINDOW(RETVAL),modal);
    OUTPUT:
        RETVAL

        
void pgk_dialog_add(widget,area="vbox",add)
        void *widget;
        char *area;
        void *add;
    CODE:
        init();
        { GtkDialog *dlg=(GtkDialog *) widget;
          if (strcmp(area,"vbox")==0) {
            add_widget((void *) dlg->vbox,add);
          }
          else {
            add_widget((void *) dlg->action_area,add);
          }
        }
        
        
        
void *pgk_text_new(text,editable=1)
        char *text;
        int   editable;
    CODE:
        init();
        {GtkText *txt=(GtkText *) gtk_text_new(NULL,NULL);
          gtk_text_set_editable(txt,editable);
          RETVAL=(void *) txt;
            }
    OUTPUT:
        RETVAL
        

        
void *pgk_entry_new(text,editable=1)
        char *text;
        int   editable;
    CODE:
        init();
        { GtkEntry *txt=(GtkEntry *) gtk_entry_new();
            gtk_entry_set_text(txt,text);
            gtk_entry_set_editable(txt,editable);
            RETVAL=(void *) txt;
        }
    OUTPUT:
        RETVAL
        
void pgk_entry_set(entry,text,editable=1)
        void *entry;
        char *text;
        int   editable;
    CODE:
        init();
        {
          gtk_entry_set_text((GtkEntry *) entry,text);
          gtk_entry_set_editable((GtkEntry *) entry, editable);
        }
        
char *pgk_entry_get(entry)
        void *entry;
    CODE:
        init();
        {
            RETVAL=gtk_entry_get_text((GtkEntry *) entry);
        }       
    OUTPUT:
        RETVAL
        
        
        
void *pgk_label_new(label,justify="left")
        char *label;
        char *justify;
    CODE:
        init();
        {
          GtkLabel *L;
              L=(GtkLabel *) gtk_label_new(strdup(label));
              gtk_label_set_justify(L,_justify(justify));
              RETVAL=(void *) L;
        }
    OUTPUT:
        RETVAL
        
void pgk_label_set(label, text, justify="left")
        void *label;
        char *text;
        char *justify;
    CODE:
        init();
        gtk_label_set_text((GtkLabel *) label,text);
                
char *pgk_label_get(label)
        void *label;
    CODE:
        {
          char *s;
            gtk_label_get((GtkLabel *) label,&s);
            RETVAL=s;
        }
    OUTPUT:
        RETVAL
                        
        
void *pgk_hbox_new(homogenous=0,spacing=1)
        int homogenous;
        int spacing;
    CODE:
        init();
        RETVAL=(void *) gtk_hbox_new(homogenous,spacing);
    OUTPUT:
        RETVAL
        
        
void *pgk_vbox_new(homogenous=0,spacing=1)
        int homogenous;
        int spacing;
    CODE:
        init();
        RETVAL=(void *) gtk_vbox_new(homogenous,spacing);
    OUTPUT:
        RETVAL
                

void *pgk_grid_new(rows=2,cols=2,homogenous=0)
        int rows;
        int cols;
        int homogenous;
    CODE:
        init();
        RETVAL=(void *) gtk_table_new(rows,cols,homogenous);
    OUTPUT:
        RETVAL
        
