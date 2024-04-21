import 'dart:math';
List<double> score(List<double> input) {
    double var0;
    if (input[4] < 8385.0) {
        if (input[1] < 56.0) {
            var0 = -0.22295283;
        } else {
            if (input[0] < 4.0) {
                var0 = 0.5022964;
            } else {
                var0 = -0.034060363;
            }
        }
    } else {
        if (input[2] < -125.0) {
            var0 = -0.07032844;
        } else {
            var0 = -0.32585162;
        }
    }
    double var1;
    if (input[1] < 76.0) {
        if (input[2] < 1893.0) {
            var1 = -0.30752373;
        } else {
            var1 = -0.03945786;
        }
    } else {
        if (input[4] < 8385.0) {
            if (input[1] < 301.0) {
                if (input[3] < -465.0) {
                    var1 = 0.37927532;
                } else {
                    var1 = 0.08978507;
                }
            } else {
                var1 = 0.076241866;
            }
        } else {
            if (input[1] < 132.0) {
                var1 = -0.03177475;
            } else {
                var1 = -0.18000112;
            }
        }
    }
    double var2;
    if (input[4] < 8385.0) {
        if (input[1] < 56.0) {
            var2 = -0.18424957;
        } else {
            if (input[2] < 1950.0) {
                if (input[1] < 135.0) {
                    var2 = 0.35408983;
                } else {
                    var2 = 0.07948792;
                }
            } else {
                var2 = -0.026833484;
            }
        }
    } else {
        if (input[2] < -125.0) {
            var2 = -0.025035195;
        } else {
            var2 = -0.2904426;
        }
    }
    double var3;
    if (input[1] < 118.0) {
        if (input[3] < -465.0) {
            var3 = 0.055547494;
        } else {
            if (input[2] < 1851.0) {
                var3 = -0.2882951;
            } else {
                var3 = -0.03847678;
            }
        }
    } else {
        if (input[1] < 308.0) {
            var3 = 0.39768627;
        } else {
            var3 = -0.10302587;
        }
    }
    double var4;
    if (input[1] < 76.0) {
        if (input[2] < 1779.0) {
            var4 = -0.262057;
        } else {
            var4 = -0.040810626;
        }
    } else {
        if (input[4] < 8204.0) {
            if (input[1] < 118.0) {
                var4 = 0.022844054;
            } else {
                var4 = 0.25975582;
            }
        } else {
            if (input[2] < -30.0) {
                var4 = 0.11468501;
            } else {
                var4 = -0.14158364;
            }
        }
    }
    double var5;
    if (input[1] < 76.0) {
        if (input[2] < 1779.0) {
            var5 = -0.24677005;
        } else {
            var5 = -0.035087552;
        }
    } else {
        if (input[4] < 8385.0) {
            if (input[1] < 308.0) {
                if (input[1] < 118.0) {
                    var5 = 0.051750872;
                } else {
                    var5 = 0.27780074;
                }
            } else {
                var5 = -0.051367547;
            }
        } else {
            var5 = -0.0906622;
        }
    }
    double var6;
    if (input[1] < 76.0) {
        if (input[2] < 1779.0) {
            var6 = -0.23153575;
        } else {
            var6 = -0.030170765;
        }
    } else {
        if (input[1] < 308.0) {
            if (input[1] < 118.0) {
                if (input[3] < -465.0) {
                    var6 = 0.1425101;
                } else {
                    var6 = -0.19052824;
                }
            } else {
                var6 = 0.22994603;
            }
        } else {
            var6 = -0.086510204;
        }
    }
    double var7;
    if (input[4] < 8385.0) {
        if (input[3] < -20.0) {
            if (input[4] < 7711.0) {
                var7 = 0.1269178;
            } else {
                if (input[2] < 1934.0) {
                    var7 = 0.022103716;
                } else {
                    var7 = -0.22238977;
                }
            }
        } else {
            var7 = 0.2124734;
        }
    } else {
        if (input[0] < 9.0) {
            var7 = -0.22706898;
        } else {
            var7 = -0.01666648;
        }
    }
    double var8;
    if (input[1] < 60.0) {
        var8 = -0.20910388;
    } else {
        if (input[2] < 1329.0) {
            if (input[3] < -152.0) {
                var8 = -0.19719054;
            } else {
                var8 = 0.08631597;
            }
        } else {
            if (input[2] < 1950.0) {
                if (input[2] < 1800.0) {
                    var8 = 0.034932792;
                } else {
                    var8 = 0.2306239;
                }
            } else {
                var8 = -0.030214064;
            }
        }
    }
    double var9;
    if (input[1] < 76.0) {
        if (input[2] < 1638.0) {
            var9 = -0.1946359;
        } else {
            var9 = -0.03447735;
        }
    } else {
        if (input[4] < 8055.0) {
            var9 = 0.14120972;
        } else {
            if (input[1] < 135.0) {
                var9 = 0.086759806;
            } else {
                var9 = -0.13832672;
            }
        }
    }
    double var10;
    if (input[1] < 118.0) {
        if (input[3] < -465.0) {
            var10 = 0.049015567;
        } else {
            if (input[2] < 1800.0) {
                var10 = -0.2131653;
            } else {
                var10 = -0.04046436;
            }
        }
    } else {
        if (input[1] < 308.0) {
            var10 = 0.16079918;
        } else {
            var10 = -0.056929637;
        }
    }
    double var11;
    if (input[1] < 60.0) {
        var11 = -0.17136055;
    } else {
        if (input[3] < -151.0) {
            if (input[4] < 7711.0) {
                var11 = 0.09932626;
            } else {
                if (input[1] < 89.0) {
                    var11 = -0.18842478;
                } else {
                    var11 = -0.03413154;
                }
            }
        } else {
            var11 = 0.13809663;
        }
    }
    double var12;
    if (input[4] < 8385.0) {
        if (input[2] < 2192.0) {
            if (input[3] < -225.0) {
                var12 = -0.01945673;
            } else {
                var12 = 0.1787543;
            }
        } else {
            var12 = -0.09929053;
        }
    } else {
        if (input[2] < -41.0) {
            var12 = -0.021765778;
        } else {
            var12 = -0.1738542;
        }
    }
    double var13;
    if (input[2] < 1329.0) {
        if (input[2] < -72.0) {
            var13 = 0.06314407;
        } else {
            var13 = -0.20610096;
        }
    } else {
        if (input[2] < 2192.0) {
            if (input[1] < 89.0) {
                var13 = -0.009445202;
            } else {
                var13 = 0.16471386;
            }
        } else {
            var13 = -0.085417755;
        }
    }
    double var14;
    if (input[4] < 8385.0) {
        if (input[4] < 8281.0) {
            if (input[4] < 7711.0) {
                var14 = 0.092184015;
            } else {
                if (input[1] < 103.0) {
                    var14 = -0.19911787;
                } else {
                    var14 = 0.05344787;
                }
            }
        } else {
            var14 = 0.13080452;
        }
    } else {
        var14 = -0.113988906;
    }
    double var15;
    if (input[1] < 76.0) {
        var15 = -0.10672033;
    } else {
        if (input[1] < 135.0) {
            if (input[0] < 3.0) {
                var15 = -0.02248764;
            } else {
                var15 = 0.20196423;
            }
        } else {
            if (input[3] < -101.0) {
                var15 = -0.12169074;
            } else {
                var15 = 0.013544853;
            }
        }
    }
    double var16;
    if (input[2] < 1329.0) {
        if (input[2] < -71.0) {
            var16 = 0.05348169;
        } else {
            var16 = -0.18066578;
        }
    } else {
        if (input[0] < 4.0) {
            if (input[2] < 1950.0) {
                var16 = 0.2099842;
            } else {
                var16 = -0.082097456;
            }
        } else {
            var16 = -0.08450096;
        }
    }
    double var17;
    if (input[4] < 8055.0) {
        var17 = 0.07228761;
    } else {
        if (input[2] < 1893.0) {
            if (input[2] < -72.0) {
                var17 = 0.048156768;
            } else {
                var17 = -0.1715383;
            }
        } else {
            var17 = 0.046689134;
        }
    }
    double var18;
    if (input[3] < -139.0) {
        if (input[4] < 7711.0) {
            var18 = 0.07168585;
        } else {
            if (input[1] < 89.0) {
                var18 = -0.17327195;
            } else {
                var18 = -0.03847795;
            }
        }
    } else {
        if (input[0] < 3.0) {
            var18 = 0.021941425;
        } else {
            var18 = 0.08493333;
        }
    }
    double var19;
    if (input[3] < -139.0) {
        if (input[0] < 4.0) {
            if (input[0] < 2.0) {
                var19 = -0.06048933;
            } else {
                var19 = 0.10902757;
            }
        } else {
            var19 = -0.16204302;
        }
    } else {
        if (input[0] < 3.0) {
            var19 = 0.018450715;
        } else {
            var19 = 0.070531815;
        }
    }
    double var20;
    if (input[2] < 1800.0) {
        if (input[2] < -70.0) {
            var20 = 0.040198978;
        } else {
            var20 = -0.108014934;
        }
    } else {
        if (input[3] < -255.0) {
            var20 = -0.07264986;
        } else {
            var20 = 0.16657488;
        }
    }
    double var21;
    if (input[1] < 76.0) {
        var21 = -0.08831358;
    } else {
        if (input[0] < 3.0) {
            if (input[2] < 1483.0) {
                var21 = -0.00056946056;
            } else {
                var21 = -0.06359015;
            }
        } else {
            var21 = 0.11074668;
        }
    }
    double var22;
    if (input[4] < 8055.0) {
        var22 = 0.06527469;
    } else {
        if (input[1] < 135.0) {
            if (input[1] < 89.0) {
                var22 = -0.07633817;
            } else {
                var22 = 0.10635371;
            }
        } else {
            var22 = -0.13526553;
        }
    }
    double var23;
    if (input[4] < 8385.0) {
        if (input[2] < 2192.0) {
            if (input[2] < 1800.0) {
                var23 = -0.011875635;
            } else {
                var23 = 0.14936784;
            }
        } else {
            var23 = -0.07684569;
        }
    } else {
        var23 = -0.082401946;
    }
    double var24;
    if (input[3] < -139.0) {
        if (input[4] < 7711.0) {
            var24 = 0.07310785;
        } else {
            var24 = -0.113547824;
        }
    } else {
        var24 = 0.054178324;
    }
    double var25;
    if (input[1] < 76.0) {
        var25 = -0.07296932;
    } else {
        if (input[1] < 135.0) {
            if (input[0] < 3.0) {
                var25 = -0.02004183;
            } else {
                var25 = 0.15756685;
            }
        } else {
            var25 = -0.05306872;
        }
    }
    double var26;
    if (input[4] < 8385.0) {
        if (input[2] < 2192.0) {
            if (input[2] < 1893.0) {
                var26 = -0.0033499077;
            } else {
                var26 = 0.14683086;
            }
        } else {
            var26 = -0.07073394;
        }
    } else {
        var26 = -0.073048614;
    }
    double var27;
    if (input[3] < -139.0) {
        if (input[4] < 7711.0) {
            var27 = 0.06769784;
        } else {
            var27 = -0.10150693;
        }
    } else {
        var27 = 0.049807783;
    }
    double var28;
    if (input[1] < 76.0) {
        var28 = -0.06723001;
    } else {
        if (input[1] < 135.0) {
            if (input[0] < 3.0) {
                var28 = -0.012239759;
            } else {
                var28 = 0.14403503;
            }
        } else {
            var28 = -0.050062988;
        }
    }
    double var29;
    if (input[4] < 8385.0) {
        if (input[4] < 8268.0) {
            if (input[4] < 7711.0) {
                var29 = 0.057444353;
            } else {
                var29 = -0.07418856;
            }
        } else {
            var29 = 0.110006906;
        }
    } else {
        var29 = -0.066440314;
    }
    double var30;
    if (input[3] < -139.0) {
        if (input[3] < -465.0) {
            var30 = 0.038737353;
        } else {
            var30 = -0.104134314;
        }
    } else {
        var30 = 0.050161928;
    }
    double var31;
    if (input[1] < 76.0) {
        var31 = -0.063753314;
    } else {
        if (input[1] < 135.0) {
            if (input[0] < 3.0) {
                var31 = -0.00026201672;
            } else {
                var31 = 0.122376956;
            }
        } else {
            var31 = -0.045072682;
        }
    }
    double var32;
    if (input[2] < 1800.0) {
        if (input[2] < -33.0) {
            var32 = 0.016806642;
        } else {
            var32 = -0.074334115;
        }
    } else {
        if (input[3] < -255.0) {
            var32 = -0.06955736;
        } else {
            var32 = 0.14641477;
        }
    }
    double var33;
    if (input[4] < 8385.0) {
        if (input[2] < 1950.0) {
            if (input[1] < 95.0) {
                var33 = 0.10271459;
            } else {
                var33 = -0.00055563945;
            }
        } else {
            var33 = -0.028292367;
        }
    } else {
        var33 = -0.06287565;
    }
    double var34;
    if (input[1] < 118.0) {
        if (input[3] < -465.0) {
            var34 = 0.054363895;
        } else {
            var34 = -0.104682006;
        }
    } else {
        if (input[1] < 301.0) {
            var34 = 0.05474356;
        } else {
            var34 = 0.013486402;
        }
    }
    double var35;
    if (input[2] < 1800.0) {
        if (input[2] < -30.0) {
            var35 = 0.016004026;
        } else {
            var35 = -0.06730551;
        }
    } else {
        if (input[3] < -255.0) {
            var35 = -0.059035875;
        } else {
            var35 = 0.12695645;
        }
    }
    double var36;
    if (input[4] < 8055.0) {
        var36 = 0.048681438;
    } else {
        if (input[4] < 8370.0) {
            var36 = -0.08115445;
        } else {
            var36 = 0.03353036;
        }
    }
    double var37;
    if (input[4] < 8385.0) {
        if (input[2] < 1950.0) {
            var37 = 0.0644691;
        } else {
            var37 = -0.030186214;
        }
    } else {
        var37 = -0.057227556;
    }
    double var38;
    if (input[0] < 2.0) {
        var38 = -0.044939876;
    } else {
        if (input[2] < 1893.0) {
            var38 = -0.060868066;
        } else {
            var38 = 0.12714182;
        }
    }
    double var39;
    if (input[1] < 135.0) {
        if (input[1] < 89.0) {
            var39 = -0.017206969;
        } else {
            var39 = 0.0734339;
        }
    } else {
        var39 = -0.042818137;
    }
    double var40;
    if (input[1] < 118.0) {
        if (input[3] < -465.0) {
            var40 = 0.051064916;
        } else {
            var40 = -0.09783982;
        }
    } else {
        var40 = 0.03820652;
    }
    double var41;
    if (input[0] < 2.0) {
        var41 = -0.04078542;
    } else {
        if (input[2] < 1893.0) {
            var41 = -0.05256331;
        } else {
            var41 = 0.111424856;
        }
    }
    double var42;
    if (input[2] < 1950.0) {
        if (input[1] < 132.0) {
            var42 = 0.08360941;
        } else {
            var42 = -0.04821945;
        }
    } else {
        var42 = -0.05007628;
    }
    double var43;
    if (input[1] < 118.0) {
        if (input[3] < -465.0) {
            var43 = 0.042628627;
        } else {
            var43 = -0.09445125;
        }
    } else {
        var43 = 0.037574477;
    }
    double var44;
    if (input[3] < -139.0) {
        if (input[1] < 95.0) {
            var44 = 0.026726868;
        } else {
            var44 = -0.080639884;
        }
    } else {
        var44 = 0.039931923;
    }
    double var45;
    if (input[2] < 1950.0) {
        if (input[1] < 132.0) {
            var45 = 0.07059726;
        } else {
            var45 = -0.04358727;
        }
    } else {
        var45 = -0.045663297;
    }
    double var46;
    if (input[1] < 118.0) {
        if (input[3] < -465.0) {
            var46 = 0.03380694;
        } else {
            var46 = -0.090545334;
        }
    } else {
        var46 = 0.03651275;
    }
    double var47;
    if (input[0] < 4.0) {
        if (input[0] < 2.0) {
            var47 = -0.03738071;
        } else {
            var47 = 0.09223433;
        }
    } else {
        var47 = -0.04251259;
    }
    double var48;
    if (input[1] < 118.0) {
        if (input[3] < -465.0) {
            var48 = 0.0269862;
        } else {
            var48 = -0.081188485;
        }
    } else {
        var48 = 0.034202706;
    }
    double var49;
    if (input[3] < -139.0) {
        if (input[1] < 95.0) {
            var49 = 0.017117864;
        } else {
            var49 = -0.0704154;
        }
    } else {
        var49 = 0.036763016;
    }
    double var50;
    if (input[2] < 1950.0) {
        if (input[1] < 132.0) {
            var50 = 0.066009596;
        } else {
            var50 = -0.04337046;
        }
    } else {
        var50 = -0.04140801;
    }
    double var51;
    if (input[1] < 118.0) {
        var51 = -0.036742005;
    } else {
        var51 = 0.03327719;
    }
    double var52;
    if (input[2] < 1800.0) {
        var52 = -0.036995027;
    } else {
        var52 = 0.03397391;
    }
    double var53;
    if (input[4] < 8055.0) {
        var53 = 0.03542441;
    } else {
        if (input[4] < 8370.0) {
            var53 = -0.08076738;
        } else {
            var53 = 0.03632219;
        }
    }
    double var54;
    if (input[2] < 1950.0) {
        if (input[2] < 1329.0) {
            var54 = -0.03716229;
        } else {
            var54 = 0.070483774;
        }
    } else {
        var54 = -0.041207828;
    }
    double var55;
    if (input[1] < 118.0) {
        var55 = -0.03133868;
    } else {
        var55 = 0.029285457;
    }
    double var56;
    if (input[1] < 135.0) {
        if (input[2] < 1461.0) {
            var56 = 0.05344287;
        } else {
            var56 = -0.008434019;
        }
    } else {
        var56 = -0.039055992;
    }
    double var57;
    if (input[2] < 1800.0) {
        var57 = -0.032440174;
    } else {
        var57 = 0.032181878;
    }
    double var58;
    if (input[0] < 4.0) {
        if (input[1] < 95.0) {
            var58 = 0.062482815;
        } else {
            var58 = -0.024797829;
        }
    } else {
        var58 = -0.037723966;
    }
    double var59;
    if (input[1] < 118.0) {
        var59 = -0.034618653;
    } else {
        var59 = 0.035150707;
    }
    double var60;
    if (input[4] < 8281.0) {
        if (input[3] < -368.0) {
            var60 = 0.0119317025;
        } else {
            var60 = -0.04962656;
        }
    } else {
        var60 = 0.032311764;
    }
    double var61;
    if (input[1] < 118.0) {
        var61 = -0.030479984;
    } else {
        var61 = 0.030272724;
    }
    double var62;
    if (input[1] < 135.0) {
        if (input[2] < 1461.0) {
            var62 = 0.05069734;
        } else {
            var62 = -0.0069202227;
        }
    } else {
        var62 = -0.03593469;
    }
    double var63;
    if (input[2] < 1800.0) {
        var63 = -0.031353287;
    } else {
        var63 = 0.032418076;
    }
    double var64;
    if (input[3] < -139.0) {
        if (input[2] < 1804.0) {
            var64 = 0.00015123664;
        } else {
            var64 = -0.04160545;
        }
    } else {
        var64 = 0.032280494;
    }
    double var65;
    if (input[4] < 8055.0) {
        var65 = 0.03585521;
    } else {
        if (input[4] < 8370.0) {
            var65 = -0.07041051;
        } else {
            var65 = 0.027615467;
        }
    }
    double var66;
    if (input[0] < 2.0) {
        var66 = -0.03369668;
    } else {
        if (input[2] < 1851.0) {
            var66 = -0.05211358;
        } else {
            var66 = 0.09705879;
        }
    }
    double var67;
    if (input[2] < 1950.0) {
        if (input[2] < 1329.0) {
            var67 = -0.029523568;
        } else {
            var67 = 0.06862172;
        }
    } else {
        var67 = -0.04147855;
    }
    double var68;
    if (input[1] < 118.0) {
        var68 = -0.029303735;
    } else {
        var68 = 0.029540611;
    }
    double var69;
    if (input[1] < 135.0) {
        if (input[2] < 1525.0) {
            var69 = 0.048854236;
        } else {
            var69 = -0.005271795;
        }
    } else {
        var69 = -0.036158614;
    }
    double var70;
    if (input[0] < 4.0) {
        if (input[1] < 95.0) {
            var70 = 0.057322893;
        } else {
            var70 = -0.019630423;
        }
    } else {
        var70 = -0.035823006;
    }
    double var71;
    if (input[1] < 118.0) {
        var71 = -0.032632086;
    } else {
        var71 = 0.033602484;
    }
    double var72;
    if (input[1] < 135.0) {
        if (input[0] < 3.0) {
            var72 = -0.008230808;
        } else {
            var72 = 0.045890927;
        }
    } else {
        var72 = -0.03117844;
    }
    double var73;
    if (input[1] < 118.0) {
        var73 = -0.029720044;
    } else {
        var73 = 0.031038282;
    }
    double var74;
    if (input[0] < 4.0) {
        if (input[1] < 95.0) {
            var74 = 0.056440886;
        } else {
            var74 = -0.01954646;
        }
    } else {
        var74 = -0.03526787;
    }
    double var75;
    if (input[1] < 118.0) {
        var75 = -0.029552987;
    } else {
        var75 = 0.030213617;
    }
    double var76;
    if (input[1] < 135.0) {
        if (input[0] < 3.0) {
            var76 = -0.0054532904;
        } else {
            var76 = 0.04436869;
        }
    } else {
        var76 = -0.0318041;
    }
    double var77;
    if (input[1] < 118.0) {
        var77 = -0.02733953;
    } else {
        var77 = 0.02843306;
    }
    double var78;
    if (input[0] < 4.0) {
        if (input[1] < 95.0) {
            var78 = 0.054623663;
        } else {
            var78 = -0.019047657;
        }
    } else {
        var78 = -0.034284096;
    }
    double var79;
    if (input[1] < 118.0) {
        var79 = -0.027569212;
    } else {
        var79 = 0.02796816;
    }
    double var80;
    if (input[1] < 135.0) {
        if (input[4] < 8281.0) {
            var80 = 0.005460904;
        } else {
            var80 = 0.032858912;
        }
    } else {
        var80 = -0.031620543;
    }
    double var81;
    if (input[4] < 8163.0) {
        var81 = 0.03110761;
    } else {
        var81 = -0.025903393;
    }
    double var82;
    if (input[1] < 118.0) {
        var82 = -0.026221862;
    } else {
        var82 = 0.027300648;
    }
    double var83;
    if (input[1] < 135.0) {
        if (input[4] < 8273.0) {
            var83 = 0.0059523056;
        } else {
            var83 = 0.03187175;
        }
    } else {
        var83 = -0.030817112;
    }
    double var84;
    if (input[1] < 236.0) {
        if (input[2] < 1461.0) {
            var84 = 0.02797341;
        } else {
            var84 = -0.05066636;
        }
    } else {
        var84 = 0.033586074;
    }
    double var85;
    if (input[2] < 1800.0) {
        var85 = -0.026103288;
    } else {
        var85 = 0.028976243;
    }
    double var86;
    if (input[2] < 1950.0) {
        if (input[2] < 1329.0) {
            var86 = -0.027937267;
        } else {
            var86 = 0.06067779;
        }
    } else {
        var86 = -0.032137588;
    }
    double var87;
    if (input[3] < -139.0) {
        var87 = -0.024247106;
    } else {
        var87 = 0.028402451;
    }
    double var88;
    if (input[4] < 8055.0) {
        var88 = 0.031811114;
    } else {
        if (input[3] < -132.0) {
            var88 = 0.016050965;
        } else {
            var88 = -0.04974817;
        }
    }
    double var89;
    if (input[4] < 8281.0) {
        var89 = -0.024154417;
    } else {
        var89 = 0.030481365;
    }
    double var90;
    if (input[4] < 8163.0) {
        var90 = 0.02873975;
    } else {
        var90 = -0.02378618;
    }
    double var91;
    if (input[3] < -139.0) {
        var91 = -0.024620866;
    } else {
        var91 = 0.029052075;
    }
    double var92;
    if (input[0] < 4.0) {
        if (input[1] < 95.0) {
            var92 = 0.04895898;
        } else {
            var92 = -0.015164364;
        }
    } else {
        var92 = -0.032724243;
    }
    double var93;
    if (input[1] < 118.0) {
        var93 = -0.026484584;
    } else {
        var93 = 0.027163008;
    }
    double var94;
    if (input[1] < 135.0) {
        var94 = 0.023980018;
    } else {
        var94 = -0.029604139;
    }
    double var95;
    if (input[1] < 118.0) {
        var95 = -0.026028667;
    } else {
        var95 = 0.025654824;
    }
    double var96;
    if (input[1] < 135.0) {
        var96 = 0.022698496;
    } else {
        var96 = -0.028939188;
    }
    double var97;
    if (input[1] < 236.0) {
        if (input[3] < -212.0) {
            var97 = 0.01922339;
        } else {
            var97 = -0.054214027;
        }
    } else {
        var97 = 0.032510594;
    }
    double var98;
    if (input[3] < -139.0) {
        var98 = -0.026166925;
    } else {
        var98 = 0.02822052;
    }
    double var99;
    if (input[2] < 1950.0) {
        if (input[2] < 1329.0) {
            var99 = -0.02503706;
        } else {
            var99 = 0.05443665;
        }
    } else {
        var99 = -0.031469632;
    }
    double var100;
    var100 = sigmoid(var0 + var1 + var2 + var3 + var4 + var5 + var6 + var7 + var8 + var9 + var10 + var11 + var12 + var13 + var14 + var15 + var16 + var17 + var18 + var19 + var20 + var21 + var22 + var23 + var24 + var25 + var26 + var27 + var28 + var29 + var30 + var31 + var32 + var33 + var34 + var35 + var36 + var37 + var38 + var39 + var40 + var41 + var42 + var43 + var44 + var45 + var46 + var47 + var48 + var49 + var50 + var51 + var52 + var53 + var54 + var55 + var56 + var57 + var58 + var59 + var60 + var61 + var62 + var63 + var64 + var65 + var66 + var67 + var68 + var69 + var70 + var71 + var72 + var73 + var74 + var75 + var76 + var77 + var78 + var79 + var80 + var81 + var82 + var83 + var84 + var85 + var86 + var87 + var88 + var89 + var90 + var91 + var92 + var93 + var94 + var95 + var96 + var97 + var98 + var99);
    return [1.0 - var100, var100];
}
double sigmoid(double x) {
    if (x < 0.0) {
        double z = exp(x);
        return z / (1.0 + z);
    }
    return 1.0 / (1.0 + exp(-x));
}
