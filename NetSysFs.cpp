#include "NetSysFs.hpp"
#include <boost/filesystem.hpp>

template<typename T>
T NetSysFs::getAttrValue(const std::string &device, const std::string &attr) {

    static const boost::filesystem::path C_SYS_CLASS("/sys/class/net");

    T value;
    boost::filesystem::path devPath(C_SYS_CLASS / device);
    if (!boost::filesystem::exists(devPath)) {
        throw std::runtime_error("Device not found");
    }
    boost::filesystem::path attrFilePath = (devPath / attr);
    if (!boost::filesystem::exists(attrFilePath) ||
            !boost::filesystem::is_regular_file(attrFilePath))
    {
        throw std::runtime_error("Attribute not found");
    }
    boost::filesystem::ifstream attrFile(attrFilePath);
    attrFile >> value;
    return value;
}


template bool NetSysFs::getAttrValue(const std::string &device, const std::string &attr);
template int NetSysFs::getAttrValue(const std::string &device, const std::string &attr);
template char NetSysFs::getAttrValue(const std::string &device, const std::string &attr);
template std::string NetSysFs::getAttrValue(const std::string &device, const std::string &attr);
