package com.geoguideai.geoguide_ai;
public final class B1PolicyChecks {
 private static int count;
 private static void verify(boolean value) { if (!value) throw new AssertionError("B1 policy"); count++; }
 public static void main(String[] args) {
  B1Policy p = B1Policy.INSTANCE;
  verify(p.producerPermissionValid(false, false));
  verify(p.producerPermissionValid(true, true));
  verify(!p.producerPermissionValid(true, false));
  verify(p.canStart(true, false, 1024));
  verify(!p.canStart(false, false, 1024));
  verify(!p.canStart(true, true, 1024));
  verify(!p.canStart(true, false, 0));
  verify(!p.canStart(true, false, 5242881));
  for (int sdk : new int[]{24,28,29,31,33,34,36}) {
   verify(p.canContinue(sdk,true,false,true,true,true));
   verify(p.canContinue(sdk,false,true,true,true,true));
   verify(!p.canContinue(sdk,false,false,true,true,true));
   verify(!p.canContinue(sdk,true,true,false,true,true));
   verify(!p.canContinue(sdk,true,true,true,false,true));
   verify(p.canContinue(sdk,true,false,true,true,false) == (sdk < 33));
  }
  System.out.println("B1_NATIVE_POLICY_ASSERTIONS_PASS=" + count);
 }
}
