synchronized (obj) {
  while (<condition is not true>) {
    obj.wait()
  }
}