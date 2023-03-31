{ pkgs, ... }:

{
  enable = true;

  signing = {
    key = "C4CC649D7F58611D";
    signByDefault = true;
  };

  userEmail = "jonjo@jonjomckay.com";
  userName = "Jonjo McKay";
}
