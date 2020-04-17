import os
import csv
import random
from _sqlite3 import connect

# user-configurable fields
card_csv_path = './csv/cardinfo.csv'
player_csv_path = 'csv/heroes.csv'
dbpath = './db/game.db'
suits = {'Spades': '♠',
         'Clubs': '♣',
         'Hearts': '♥',
         'Diamonds': '♦'}


# TODO: Working Mana management + new stuff per turn
# TODO: 4-player functionality
# TODO: Combine character stats like atk/def with the cards played, in the damage/buff methods in Player
# TODO: Create reasonable mana consumption / regeneration system for players
# TODO: 12/52 cards finished
# TODO: Write a simple AI
# TODO: Commission art
# TODO: Future turn stats
# TODO: base stats
# TODO: Cross-compatible GUI via a Curses-like interface / webapp / tkinter / pyqt / pygame

def enter_to_continue():
    _ = input('Press Enter to continue!')


# Trying to automate boilerplate input stuff
# Ask user for a choice of supplied list items, and it will return a 0-indexed, 0->n-1 choice.
def choice(title='Choice:', ls=['Y', 'N']) -> int:
    """

    :param title: string for display
    :param ls: list for user's informed choice
    :return: int of user's index choice of that list
    """
    print(title)
    for index, item in enumerate(ls):
        print('{}: {}'.format(index + 1, item))
    try:
        c = input(('Your choice:'))
        if c.lower() in ('i', 'p'):
            return c
        c = int(c) - 1
    # if not within valid results, return first result
    except (ValueError, TypeError):
        c = 0
    if c not in range(1, len(ls) + 1) or c == 0:
        c = 0
    return c


# returns the string of the sign of a number.
def sign(num):
    """

    :param num: integer
    :return: the past tense string of the sign's intent (increase/decrease)
    """
    sign = ''
    if num > 0:
        sign = 'increased'
    if num < 0:
        sign = 'decreased'
    if num == 0:
        return None


class Card:

    def __init__(self, uid, title, card_strength, cardname, suit, color, category, cost, hp, mp, armor,
                 atk, target, turns, info, lore, art):
        # 0-51 for now...
        self.uid = int(uid)
        self.title = title
        self.card_strength = int(card_strength)
        self.cardname = cardname
        self.suit = suit
        self.color = color
        self.category = category
        self.cost = int(cost)
        self.hp = int(hp)
        self.mp = int(mp)
        self.armor = int(armor)
        self.atk = int(atk)
        self.target = int(target)
        self.turns = int(turns)
        self.info = info
        self.lore = lore
        self.art = art
        self.datadict = {
            'uid': self.uid,
            'title': self.title,
            'card_strength': self.card_strength,
            'cardname': self.cardname,
            'suit': self.suit,
            'color': self.color,
            'category': self.category,
            'cost': self.cost,
            'hp': self.hp,
            'mp': self.mp,
            'armor': self.armor,
            'atk': self.atk,
            'target': self.target,
            'turns': self.turns,
            'info': self.info,
            'lore': self.lore,
            'art': self.art
        }

    def __str__(self):
        return str(self.datadict)

    # TODO: Make prettier
    def prettyprint(self, index=None):
        t = 'Self' if self.target == 0 else 'Opponent'
        print(
            'Card {}:「{}」:{} of {}. Category:{}\n'.format(index, self.title, self.cardname, suits[self.suit],
                                                          self.category),
            '\tInfo:{}\n'.format(self.info),
            '\tCost:{} Turns:{} Target:{} HP:{} MP:{}\n'.format(self.cost, self.turns, t, self.hp, self.mp),
            '\tDef:{} Atk:{} \n'.format(self.armor, self.atk),
            '\tLore:{}'.format(self.lore),
        )

    def prettystr(self, index=None) -> str:
        t = 'Self' if self.target == 0 else 'Opponent'
        return str(
            'Card {}:「{}」:{} of {}. Category:{}\n'.format(index, self.title, self.cardname, suits[self.suit],
                                                          self.category) +
            '\tInfo:{}\n'.format(self.info) +
            '\tCost:{} Turns:{} Target:{} HP:{} MP:{}\n'.format(self.cost, self.turns, t, self.hp, self.mp) +
            '\tDef:{} Atk:{} \n'.format(self.armor, self.atk) +
            '\tLore:{}'.format(self.lore)
        )


class Player:
    def __init__(self, uid, title, suit, color, category, hp, mp, armor, atk, art, info):
        # ie. "Player 1, or Player 4"
        self.id: int
        self.uid = int(uid)
        self.title = title
        self.suit = suit
        self.color = color
        self.category = category

        # HP is the running total, while base is not changed and used for calculations and mod_ functions
        self.hp = int(hp)
        self.basehp = int(self.hp)

        self.mp = int(mp)
        self.basemp = int(self.mp)

        self.armor = int(armor)
        self.basearmor = self.armor

        self.atk = int(atk)
        self.baseatk = self.atk

        self.art = art
        self.info = info
        self.hand = []
        self.hand_empty = False
        self.endturn = False
        self.alive = False
        self.datadict = {'uid': self.uid,
                         'title': self.title,
                         'suit': self.suit,
                         'color': self.color,
                         'category': self.category,
                         'hp': self.hp,
                         'mp': self.mp,
                         'armor': self.armor,
                         'atk': self.atk,
                         'art': self.art,
                         'info': self.info}

    def __dict__(self) -> dict:
        return self.datadict

    def __str__(self) -> str:
        return str(self.datadict)

    # changes base hp, only used for buffs and defbuffs
    def mod_hp(self, val):
        if sign(val):
            if self.hp <= 0:
                self.hp = 0
                print('HP is already 0!')
                self.alive = False
                return False
            self.hp += val
            print('HP {} by {}!'.format(sign(val), val))
            return True

    #
    def damage_hp(self, val):
        pass

    def mod_mp(self, val):
        if sign(val):
            if self.mp <= 0:
                self.mp = 0
                print('MP is already 0!')
                return False
            self.mp += val
            print('MP {} by {}!'.format(sign(val), val))
            return True

    def damage_mp(self, val):
        pass

    def spend_mp(self, cost):
        self.mp -= cost
        print('You spend {}MP'.format(cost))
        if self.mp <= 0:
            print('out of mana, next turn.')
            self.endturn = True

    def mod_armor(self, val):
        if sign(val):
            if self.armor <= 0:
                self.armor = 0
                print('Armor is already 0!')
                return False
            self.armor += val
            print('Armor {} by {}!'.format(sign(val), val))
            return True

    # when an offensive card damages armor
    def damage_armor(self, val):
        pass

    def mod_atk(self, val):
        if sign(val):
            if self.atk <= 0:
                self.atk = 0
                print('Attack is already 0!')
                return False
            self.atk += val
            print('Attack {} by {}!'.format(sign(val), val))
            return True

    def damage_atk(self, val):
        pass

    def printhand(self):
        print('「YOUR HAND」')
        for index, card in enumerate(self.hand):
            card: Card
            card.prettyprint(index)

    def prettyprint(self):
        print(
            'Hero Name: {}\n'.format(self.title),
            '\tHP:{} MP:{} Atk:{} Def:{}\n'.format(self.hp, self.mp, self.atk,
                                                   self.armor),
            '\tInfo: {}'.format(self.info)
        )

    def prettyprintstats(self):
        print(
            'Hero Name: {}\n'.format(self.title),
            '\tHP:{} MP:{} Atk:{} Def:{}'.format(self.hp, self.mp, self.atk,
                                                 self.armor),
        )

    def prettystatsstr(self) -> str:
        return (
                'Hero Name: {}\n'.format(self.title) +
                '\tHP:{} MP:{} Atk:{} Def:{}'.format(self.hp, self.mp, self.atk, self.armor)
        )


class Game:
    # so far, inside each game are 2 players,
    # a deck of 52 card objects (12 for now), assigned to each of their appropriate data from the CSV
    # each person draws up to 5 cards at beginning of their turn, spends as much mana as they like.
    # your turn ends when you spend all your mana, or you have no cards left.
    def __init__(self):
        self.db = Dbsetup()

        # database data retrieval
        self.herodata = self.db.herodata()
        self.carddata = self.db.carddata()

        # available heros
        self.heroes = [Player(*line) for line in self.herodata]
        self.heronames = [p.title for p in self.heroes]

        # selected heros, playing now.
        self.players = []
        self.cards = [Card(*line) for line in self.carddata]
        self.hand_size = 5
        self.mp_pool = 0
        self.whosturn = 0
        self.turncount = 1
        self.deck_empty = False
        self.playing = True

    def gameover(self):
        print('FINAL RESULT:')
        self.player1.prettyprintstats()
        self.player2.prettyprintstats()

    # TODO: Game entrypoint
    def gameloop(self):
        self.deck = self.cards.copy() * 3

        self.player1 = self.choosehero((choice(title='Choose a Hero', ls=[h.title for h in self.heroes])))
        print('Player {} is {}!'.format('1', self.player1.title))
        self.player1.prettyprint()
        enter_to_continue()

        self.player2 = self.choosehero((choice(title='Choose a Hero', ls=[h.title for h in self.heroes])))
        print('Player {} is {}!'.format('2', self.player2.title))
        self.player2.prettyprint()
        enter_to_continue()

        self.players = [self.player1, self.player2]

        while self.playing:

            # process the player's turn
            self.process_turn(self.whosturn)

            # give 1 mana to the players every other turn past the first turn
            if self.turncount % 2 == 0:
                self.mp_pool += 1

            # if deck and both hands are empty, game ends (for now).
            if self.deck_empty and self.player1.hand_empty and self.player2.hand_empty:
                self.playing = False
                self.gameover()

            # flip-flop who's turn it is.
            if self.whosturn == 1:
                self.whosturn = 0
            elif self.whosturn == 0:
                self.whosturn = 1

            # increment turn for next turn
            self.turncount += 1
        print('Game Over. Hope you had fun playing!\nColin Burke - 2020')

    # processes a single turn of a player, by playerID (0,1,2,3)
    def process_turn(self, player_id):
        ourplayer: Player
        ourplayer = self.players[player_id]

        # refresh player's mana pool
        ourplayer.mp += self.mp_pool

        # give cards to the player out of the deck
        while len(ourplayer.hand) < self.hand_size:
            try:
                ourplayer.hand.append(self.randomcard())
            except ValueError:
                print('Deck Empty!')
                self.deck_empty = True
                break

        # allow player to process as many cards until voluntarily ending turn, or until turn ends
        ourplayer.endturn = False
        while not ourplayer.endturn:
            titletext = ('======Turn {}, Player {}======\n'.format(self.turncount, player_id + 1))
            if not ourplayer.hand:
                print('Your hand is empty! End Turn.')
                ourplayer.hand_empty = True
                ourplayer.endturn = True
                break
            c = choice(titletext + '\n' + ourplayer.prettystatsstr() + '\n「YOUR HAND」',
                       ['{}: {} - Cost:{}'.format(c.title, c.info, c.cost) for c in ourplayer.hand])

            if c == 'p':
                print('Passing Turn')
                ourplayer.endturn = True
                break
            elif c == 'i':
                ourplayer.hand[c].prettyprint()
                c = choice('SELECT CARD TO GET INFO FROM:', [c.prettyprint() for c in ourplayer.hand])

                continue
            if ourplayer.hand[c].cost > ourplayer.mp:
                print('Not enough Mana! Card cost is {}MP and you only have {}MP!'.format(ourplayer.hand[c].cost,
                                                                                          ourplayer.mp))
                print('Type \'p\' to pass your turn!')
                continue
            else:
                self.process_card(ourplayer.hand.pop(c))
        ourplayer.mp = 0

    def process_card(self, c: Card):
        # Type hints are awesome for performance, and for IDE support for finding class members and stuff.
        # I started doing these a lot in this project
        target: Player

        # target 0 is self, 1 is other player
        target = self.players[c.target]

        target.spend_mp(c.cost)
        print(target.hp)
        if target.mod_hp(c.hp):
            enter_to_continue()
            print(target.hp)
        # enter_to_continue()
        target.mod_mp(c.mp)
        # enter_to_continue()
        target.mod_armor(c.armor)
        # enter_to_continue()
        target.mod_atk(c.atk)
        # enter_to_continue()
        target.mod_atk(c.atk)
        # enter_to_continue()

        # multiple turns for a card to last not implemented yet # TODO
        # ...

        if target.hp <= 0:
            print('==========DEAD==========\,{}'.format(target.prettyprint()))
            self.playing = False
            self.gameover()

    def choosehero(self, index: int):
        # we want to heroes to be unique, so we have to remove them from the database retrieved data, and the object lists we crated from them as well.
        self.heroes.pop(index)
        return Player(*self.herodata.pop(index))

    def randomcard(self):
        """

        :return: returns a random card object
        """
        return self.deck.pop(random.randrange(len(self.deck)))


class Dbsetup():
    def __init__(self):
        self.create_dirs()
        # import and create our player database
        self.conn = connect(dbpath)
        self.cur = self.conn.cursor()

        q_create = '''CREATE TABLE IF NOT EXISTS cardinfo (uid INTEGER, title TEXT, card_strength TEXT, cardname TEXT, suit TEXT, color TEXT, category TEXT, cost INTEGER, hp INTEGER, mp INTEGER, armor INTEGER, atk INTEGER, target TEXT, turns INTEGER, info TEXT, lore TEXT, art TEXT);'''

        q_insert = '''INSERT INTO cardinfo VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);'''

        self.cur.execute(q_create)
        with open('./csv/cardinfo.csv', 'r') as fin:
            dr = csv.reader(fin)
            for i in dr:
                self.cur.execute(q_insert, i)

        q_create = '''CREATE TABLE IF NOT EXISTS heroes(uid, title, suit, color, category, hp, mp, armor, atk, art, info);'''
        q_insert = '''INSERT INTO heroes VALUES (?,?,?,?,?,?,?,?,?,?,?);'''

        self.cur.execute(q_create)
        with open('./csv/heroes.csv', 'r') as fin:
            dr = csv.reader(fin)
            for i in dr:
                self.cur.execute(q_insert, i)

    # these file functions requires elevation prior to running, or write level access to the path.
    def create_dirs(self):
        database_dir = './db/'
        if not os.path.exists(database_dir):
            os.mkdir(database_dir)

        img_dir = './img/'
        if not os.path.exists(img_dir):
            os.mkdir(img_dir)

    def deletedbifexists(self):
        if os.path.exists('./db/game.db'):
            os.remove('./db/game.db')

    def carddata(self):
        q_query = '''SELECT * FROM cardinfo'''
        return self.cur.execute(q_query).fetchall()[1:]

    def herodata(self):
        q_query = '''SELECT * FROM heroes'''
        return self.cur.execute(q_query).fetchall()[1:]

    def closedb(self):
        self.conn.close()

    def opendb(self, path):
        self.conn = connect(path)
        self.cur = self.gamedb.cursor()

# retrieve player info from DB
