#   This here should find a kind of Levenshtein distance for words, but it is
#   based, as is my habit, on the layout of the keyboard, rather than being a
#   naïve implementation.
#   It is not generalised. This time, it is strictly for the phone.

#   It creates String#-, which _is_ commutative, unlike the traditional -.
#   So, 'man' - 'boy' = 'boy' - 'man'

#   Now: 'man' - 'men' = 2, and 'man' - 'mbn' = 1, which makes 'mbn' have a
#   smaller distance from 'man', because they share a key on the phone (it could
#   be a case of one pressing the key one time too many). However,
#   'man' - 'med' = 4, which places 'men' closer to 'man', in case of bad
#   spelling, than 'med'.
#   'man' - 'man' = 0, for there is no distance between the same two words.

#   An arbitrary/heuristic way to decide, sans interaction, which of the words
#   in a list were intended, if all of them were missed, is to take the one that
#   is closest, of those that are within < 3 in distance. If you get only one,
#   use that.

#   The - operator has an unspecified time complexity that is huge.
#   It is at least O(5n*n^2) on the shortest string.
#   Please use only with short strings, and sparingly. It has not been optimised
#   for speed, just for the comfort of those who may have made the spelling
#   errors (not even for the programmer).

#   TODO:
#   1.  Add accented characters to the keypad, when I get a text editor that
#       permits it.

require 'set'

PHONE_LAYOUT = %w[1.!,?@:;- 2abc 3def 4ghi 5jkl 6mno 7pqrs 8tuv 9wxyz]

class String
    def distance str
        left  = self.downcase
        right = str.downcase
        if left.length < right.length then
            left  = str.downcase
            right = self.downcase
        end
        diff = (left.length - right.length) * 2
        (0 ... right.length).map do |x|
            if right[x] == left[x] then
                0
            else
                got = PHONE_LAYOUT.find {|y| y.split('').member?(right[x].chr)}
                unless got then
                    2
                else
                    if got.split('').member?(left[x].chr) then
                        1
                    else
                        2
                    end
                end
            end
        end.inject(diff) {|p, n| p + n}
    end

    def - y
        one  = Set.new(self.downcase.split(''))
        two  = Set.new(y.downcase.split(''))
        rez = [self.distance(y),
               self.reverse.distance(y.reverse),
               (one - two).size * 2]
        if rez.delete_if {|x| x.zero?}.empty? then
            0
        else
            rez.min
        end
    end
end
