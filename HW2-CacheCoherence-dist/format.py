
import json

def main(filename):
    f = open(filename, 'r')
    data = json.loads(f.read())
    f.close()

    msi = {}
    for testname, results in data.iteritems():
        msi[testname] = {}
        for cpu, counters in results.iteritems():
            for counter, values in counters.iteritems():
                if counter not in msi: msi[testname][counter] = "0"
                prev = int(msi[testname][counter])
                msi[testname][counter] = str(prev + int(values[0]))

    mesi = {}
    for testname, results in data.iteritems():
        mesi[testname] = {}
        for cpu, counters in results.iteritems():
            for counter, values in counters.iteritems():
                if counter not in mesi: mesi[testname][counter] = "0"
                prev = int(mesi[testname][counter])
                mesi[testname][counter] = str(prev + int(values[1]))

    test_names = msi.keys()
    counter_names = msi["vips"].keys()

    f = open(filename.split('.')[0] + ".csv", 'w')
    # for testname, counters in msi.iteritems():
    #     f.write(','.join([testname, "MSI", "MESI"]) + "\n")
    #     for counter in counters.keys():
    #         if counter != "CPUId":
    #             msi_val = msi[testname][counter]
    #             mesi_val = mesi[testname][counter]
    #             f.write(','.join([counter, msi_val, mesi_val]) + "\n")
    #     f.write("\n")
    for counter in counter_names:
        if counter == "CPUId": continue
        f.write(','.join([counter, "MSI", "MESI"]) + "\n")
        for test in test_names:
            msi_val = msi[test][counter]
            mesi_val = mesi[test][counter]
            f.write(','.join([test, msi_val, mesi_val]) + "\n")
        f.write("\n")
            

    f.close()

if __name__ == "__main__":
    import sys
    main(sys.argv[1])
