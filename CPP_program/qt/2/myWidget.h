#include <QApplication>
#include <QFont>
#include <QPushButton>
#include <QWidget>

class myWidget: public QWidget
{
public:
	myWidget(QWidget *parent = 0);
};

myWidget::myWidget(QWidget *parent):QWidget(parent)
{
	setFixedSize(200,100);

	QPushButton *quit = new QPushButton(tr("Quit"), this);

	quit->setGeometry(62, 40, 75, 30);
	quit->setFont(QFont("Times", 18, QFont::Bold));

	connect(quit, SIGNAL(clicked()), qApp, SLOT(quit()));
}
