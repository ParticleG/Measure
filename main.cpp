#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtSvg>
#include "qtcv.h"
#include "fileio.h"
#include <statusbar.h>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setOrganizationName("STEA Team");
    QCoreApplication::setOrganizationDomain("hdustea.cn");
    QGuiApplication app(argc, argv);

    qmlRegisterType<QtCV>("QtCV",1,0,"QtCV");
    qmlRegisterType<StatusBar>("StatusBar", 1, 0, "StatusBar");
    qmlRegisterType<FileIO>("FileIO", 1, 0, "FileIO");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
