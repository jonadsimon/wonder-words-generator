from collections import Counter

class Square(Counter):
    """Creates a special purpose counter than can store only one value, and wipes itself when zero."""
    def __init__(self):
        """Object should be initialized empty."""
        pass

    def __setitem__(self, key, cnt):
        """Update the count."""
        # If Counter already contains another key, throw an exception.
        if len(self.keys()) > 0 and self.keys().isdisjoint(key):
            raise KeyError(f"Square already contains key '{list(self.keys()).pop()}', can't modify with key '{key}'")
        # If count is being set to zero, remove the key altogether.
        if cnt == 0:
            super().__delitem__(key)
        # Otherwise just assign the value as usual.
        else:
            super().__setitem__(key, cnt)
