"""Test runner internals for the TDAB external test suite.

This package exists so that scenario parsing, plugin component
discovery, and (eventually) SDK invocation helpers have somewhere
focused to live. The split keeps the test files themselves about
*what is being asserted* rather than *how the test gets dispatched*.
"""
