#include "qtcv.h"

#include <QDebug>
#include <QFile>

void QtCV::processImage(const QString &inputFilePath) {
    Mat rawImage = imread(inputFilePath.toStdString());
    Mat inputImage, hsvImage, thresholdImage, gaussianBlurredImage, cannyImage, dilateImage, outputImage;
    if (rawImage.cols > rawImage.rows) {
        Mat rawCopy = Mat(rawImage.rows, rawImage.cols, rawImage.depth());
        transpose(rawImage, rawCopy);
        flip(rawCopy, rawCopy, 0);
        resize(rawCopy, inputImage, Size(), 0.5, 0.5, 3);
    } else {
        resize(rawImage, inputImage, Size(), 0.5, 0.5, 3);
    }

    QFile file(":/maskImage.jpg");
    Mat   maskImage, maskedImage;
    if (file.open(QIODevice::ReadOnly)) {
        qint64             sz = file.size();
        std::vector<uchar> buf(sz);
        file.read((char *)buf.data(), sz);
        maskImage = imdecode(buf, IMREAD_GRAYSCALE);
    }

    cvtColor(inputImage, hsvImage, COLOR_BGR2HSV);
    vector<Mat> channels;
    split(hsvImage, channels);
    equalizeHist(channels[2], channels[2]);
    merge(channels, hsvImage);

    Mat tempThresholdImage;
    inRange(hsvImage, Scalar(156, 60, 90), Scalar(180, 255, 255), tempThresholdImage);
    inRange(hsvImage, Scalar(0, 60, 90), Scalar(10, 255, 255), thresholdImage);
    addWeighted(tempThresholdImage, 1, thresholdImage, 1, 0, thresholdImage);
    thresholdImage.copyTo(maskedImage, maskImage);
    imwrite(inputFilePath.left(inputFilePath.lastIndexOf("/")).toStdString() + "/maskedImage.jpg", maskedImage);

    dilate(maskedImage, maskedImage, getStructuringElement(MORPH_RECT, Size(3, 3)));
    erode(maskedImage, maskedImage, getStructuringElement(MORPH_RECT, Size(5, 5)));
    dilate(maskedImage, maskedImage, getStructuringElement(MORPH_RECT, Size(6, 6)));
    erode(maskedImage, maskedImage, getStructuringElement(MORPH_RECT, Size(7, 7)));
    dilate(maskedImage, dilateImage, getStructuringElement(MORPH_RECT, Size(7, 7)));
    imwrite(inputFilePath.left(inputFilePath.lastIndexOf("/")).toStdString() + "/dilateImage.jpg", dilateImage);

    outputImage = inputImage.clone();
    displayAngle(dilateImage, outputImage);
    imwrite(inputFilePath.left(inputFilePath.lastIndexOf("/")).toStdString() + "/outputImage.jpg", outputImage);
}

void QtCV::displayAngle(Mat sourceImage, Mat destinationImage) {
    Point center = Point(sourceImage.cols / 2, sourceImage.rows / 2);
    circle(destinationImage, center, 2, Scalar(255, 255, 0), 5);

    vector<Vec4i> houghLines;
    Vec4d         refractedLight;

    HoughLinesP(sourceImage, houghLines, 1, CV_PI / 720, 50, 100, 30);
    if (!houghLines.empty()) { refractedLight = houghLines[0]; }
    int lineCount = 0;
    for (const auto &houghLine : houghLines) {
        lineCount++;
        if (pow(houghLine[2] - houghLine[0], 2.0) + pow(houghLine[3] - houghLine[1], 2.0) > pow(refractedLight[2] - refractedLight[0], 2.0) + pow(refractedLight[3] - refractedLight[1], 2.0)) { refractedLight = houghLine; }
    }
    line(destinationImage, Point(refractedLight[0], refractedLight[1]), Point(refractedLight[2], refractedLight[3]), Scalar(255, 191, 0), 3);
    line(destinationImage, center, Point(refractedLight[0], refractedLight[1]), Scalar(0, 255, 0), 3);
    line(destinationImage, center, Point(refractedLight[2], refractedLight[3]), Scalar(0, 255, 0), 3);

    double angle = acos(sqrt(pow(refractedLight[2] - refractedLight[0], 2.0) + pow(refractedLight[3] - refractedLight[1], 2.0)) / 2.0 / sqrt(pow(refractedLight[2] - center.x, 2.0) + pow(refractedLight[3] - center.y, 2.0)));
    qDebug() << "lineCount: " << lineCount << Qt::endl;
    qDebug() << "angle: " << angle * (180.0 / CV_PI) << Qt::endl;

    _center.setX(center.x);
    _center.setY(center.y);
    _refractedLight.setX(refractedLight[0]);
    _refractedLight.setY(refractedLight[1]);
    _refractedLight.setZ(refractedLight[2]);
    _refractedLight.setW(refractedLight[3]);
    emit processCompleted(_center, _refractedLight, angle);
}
