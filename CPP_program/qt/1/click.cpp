#include <QApplication>
#include <QPushButton>
#include <QFont>
#include <QWidget>

int main(int argc, const char *argv[])
{
        QApplication app(argc, (char **)argv);
        QPushButton quit("click quit");
        QWidget window;
        window.resize(300,500);

        quit.setFont(QFont("Times", 18, QFont::Bold));
        quit.setGeometry(10, 40, 180, 40);

        QObject::connect(&quit, SIGNAL(clicked()), &app, SLOT(quit()));

        quit.show();
//        hello.show();
        return app.exec();
}


