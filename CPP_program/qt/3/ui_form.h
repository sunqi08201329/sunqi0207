/********************************************************************************
** Form generated from reading UI file 'form.ui'
**
** Created: Wed Jun 13 17:37:19 2012
**      by: Qt User Interface Compiler version 4.8.1
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_FORM_H
#define UI_FORM_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QHeaderView>
#include <QtGui/QLCDNumber>
#include <QtGui/QPushButton>
#include <QtGui/QSlider>
#include <QtGui/QWidget>

QT_BEGIN_NAMESPACE

class Ui_Form
{
public:
    QLCDNumber *lcd;
    QPushButton *quit;
    QSlider *slider;

    void setupUi(QWidget *Form)
    {
        if (Form->objectName().isEmpty())
            Form->setObjectName(QString::fromUtf8("Form"));
        Form->resize(387, 353);
        lcd = new QLCDNumber(Form);
        lcd->setObjectName(QString::fromUtf8("lcd"));
        lcd->setGeometry(QRect(190, 130, 64, 23));
        quit = new QPushButton(Form);
        quit->setObjectName(QString::fromUtf8("quit"));
        quit->setGeometry(QRect(298, 105, 80, 26));
        slider = new QSlider(Form);
        slider->setObjectName(QString::fromUtf8("slider"));
        slider->setGeometry(QRect(9, 233, 84, 16));
        slider->setOrientation(Qt::Horizontal);

        retranslateUi(Form);

        QMetaObject::connectSlotsByName(Form);
    } // setupUi

    void retranslateUi(QWidget *Form)
    {
        Form->setWindowTitle(QApplication::translate("Form", "Form", 0, QApplication::UnicodeUTF8));
        quit->setText(QApplication::translate("Form", "quit", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class Form: public Ui_Form {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_FORM_H
