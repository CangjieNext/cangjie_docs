// package a
public class Foo {}

// package b
public interface Bar {}

// package c
import a.Foo
import b.Bar

extend Foo <: Bar {} // Error