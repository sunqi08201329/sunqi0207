#include <QApplication>
#include "ui_form.h"
#include <QFont>
#include <QPushButton>
#include <QWidget>
#include <QMessageBox>

class myWidget: public QWidget, public  Ui_Form
{
	Q_OBJECT
public:
	myWidget(QWidget *parent = 0);
public slots:
	void myquit();
	
};
void myWidget::myquit()
{
	if(QMessageBox::Ok == QMessageBox::question(this, tr("abcd"), tr("?"), QMessageBox::Ok|QMessageBox::Cancel))
		qApp->quit();

}

myWidget::myWidget(QWidget *parent):QWidget(parent)
{
	setupUi(this);

	/*QLCDNumber *lcd;*/
	/*QPushButton *quit;*/
	/*QSlider *slider;*/

	quit->setFont(QFont("Times", 18, QFont::Bold));

	connect(quit, SIGNAL(clicked()), qApp, SLOT(myquit()));

	lcd->setSegmentStyle(QLCDNumber::Filled);




	slider->setRange(0,99);
        slider->setValue(0);
	connect(slider, SIGNAL(valueChanged(int)), lcd, SLOT(dispaly(int)));
}
