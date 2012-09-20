#include "myWidget.h"

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	myWidget widget;
	widget.show();
	return app.exec();
}
