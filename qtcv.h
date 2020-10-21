#ifndef QTCV_H
#define QTCV_H

//#include <QQuickImageProvider>
#include <QImage>
#include <QObject>
#include <QVector2D>
#include <QVector4D>
#include <opencv2/opencv.hpp>
//#include <QOpenCVProcessing.hpp>

using namespace cv;
using namespace std;

class QtCV : public QObject
{
    Q_OBJECT

public slots:
    void processImage(const QString &inputFilePath);

signals:
    void processCompleted(QVector2D _center, QVector4D _refractedLight, double _angle);

private:
    void displayAngle(Mat sourceImage, Mat destinationImage);

    QVector2D _center;
    QVector4D _refractedLight;
};

#endif // QTCV_H
