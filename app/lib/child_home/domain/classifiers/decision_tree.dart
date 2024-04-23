List<double> score(List<double> input) {
    List<double> var0;
    if (input[4] <= 8380.0) {
        if (input[4] <= 8369.5) {
            if (input[1] <= 74.5) {
                var0 = [1.0, 0.0];
            } else {
                if (input[2] <= 891.5) {
                    var0 = [1.0, 0.0];
                } else {
                    if (input[2] <= 1477.5) {
                        var0 = [0.0, 1.0];
                    } else {
                        if (input[1] <= 117.5) {
                            if (input[4] <= 7833.0) {
                                var0 = [0.0, 1.0];
                            } else {
                                var0 = [1.0, 0.0];
                            }
                        } else {
                            if (input[2] <= 2175.0) {
                                if (input[0] <= 31.5) {
                                    var0 = [0.0, 1.0];
                                } else {
                                    var0 = [1.0, 0.0];
                                }
                            } else {
                                var0 = [1.0, 0.0];
                            }
                        }
                    }
                }
            }
        } else {
            var0 = [0.0, 1.0];
        }
    } else {
        if (input[2] <= -123.0) {
            if (input[0] <= 8.0) {
                var0 = [1.0, 0.0];
            } else {
                var0 = [0.0, 1.0];
            }
        } else {
            var0 = [1.0, 0.0];
        }
    }
    return var0;
}
