#include "simplecache.h"

int SimpleCache::find(int index, int tag, int block_offset) {
  // read handout for implementation details
  std::vector<SimpleCacheBlock> &v = _cache[index];
  for (std::vector<SimpleCacheBlock>::iterator it = v.begin(); it != v.end(); ++it) {
    if ((it->tag() == tag) && it->valid()) {
      return it->get_byte(block_offset);
    }
  }
  return 0xdeadbeef;
}

void SimpleCache::insert(int index, int tag, char data[]) {
  // read handout for implementation details
  // keep in mind what happens when you assign (see "C++ Rule of Three")
  std::vector<SimpleCacheBlock> &v = _cache[index];
  for (std::vector<SimpleCacheBlock>::iterator it = v.begin(); it != v.end(); ++it) {
    if (!(it->valid())) {
      it->replace(tag, data);
      return;
    }
  }
  _cache[index][0].replace(tag, data);
}
