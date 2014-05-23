
def main(filename):
    results = {}
    current = ""
    # current_prog = ""
    parsing_results = False
    items = []

    f = open(filename, 'r')

    for line in f:
        if parsing_results:
            # print "nums: " + line
            nums = line.strip().split(",")
            cpu_id = nums[0]
            if cpu_id not in results[current]:
                results[current][cpu_id] = {}
            for pair in zip(items, nums):
                if pair[0] not in results[current][cpu_id]:
                    results[current][cpu_id][pair[0]] = []
                results[current][cpu_id][pair[0]].append(pair[1])
            parsing_results = False
        else:
            if "Running benchmark" in line:
                current = line.split()[4]
                results[current] = {}
                # print "parsing: " + current
            elif line.startswith("CPUId"):
                parsing_results = True
                items = line.strip().split(", ")
                # print "items: ",  items

    f.close()

    for test, results in results.iteritems():
        print test
        for cpu_id, nums in results.iteritems():
            print "\tCPU: %s" %(cpu_id)
            for item, num in nums.iteritems():
                print "\t\t%s: %s" % (item, ", ".join(num))

if __name__ == "__main__":
    import sys
    main(sys.argv[1])
