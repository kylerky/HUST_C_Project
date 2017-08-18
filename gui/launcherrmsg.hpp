#ifndef LAUNCHERRMSG_H
#define LAUNCHERRMSG_H

#include <string>
#include <QObject>

namespace HUST_C {

namespace ErrorMsg {
    extern std::string errMsg;
}

class LaunchErrMsg : public QObject {
    Q_OBJECT
public:
    LaunchErrMsg() : QObject(){}
public slots:
    static QString what() {
        return QString::fromStdString(ErrorMsg::errMsg);
    }
};

} // namespace HUST_C

#endif  // LAUNCHERRMSG_H
