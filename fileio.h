#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QFile>
#include <QDir>
#include <QTextStream>

class FileIO : public QObject
{
    Q_OBJECT

public slots:
    bool write(const QString& source, const QString& data);
    bool ensure(const QString& source);
};

#endif // FILEIO_H
