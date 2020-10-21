#include "fileio.h"

bool FileIO::write(const QString& source, const QString& data) {
    if (source.isEmpty())
        return false;

    QFile file(source);
    if (!file.open(QFile::WriteOnly | QFile::Truncate))
        return false;

    QTextStream out(&file);
    out << data;
    file.close();
    return true;
}

bool FileIO::ensure(const QString& source) {
    if (source.isEmpty()){
        return false;
    }
    QDir directory(source);
    if (!directory.exists()){
        QDir parentDirectory(source.left(source.length() - directory.dirName().length()));
        return parentDirectory.mkdir(directory.dirName());
    }
    return true;
}
