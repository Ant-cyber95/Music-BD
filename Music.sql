-- your code goes here
-- =============================================
-- УДАЛЕНИЕ ТАБЛИЦ (если существуют)
-- =============================================

DROP TABLE IF EXISTS collection_tracks;
DROP TABLE IF EXISTS collections;
DROP TABLE IF EXISTS tracks;
DROP TABLE IF EXISTS artist_albums;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS artist_genres;
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS genres;

-- =============================================
-- СОЗДАНИЕ ТАБЛИЦ
-- =============================================

-- 1. Жанры
CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Исполнители
CREATE TABLE artists (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL
);

-- 3. Связь исполнителей и жанров (M:M)
CREATE TABLE artist_genres (
    artist_id INTEGER NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    genre_id INTEGER NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (artist_id, genre_id)
);

-- 4. Альбомы
CREATE TABLE albums (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    year INTEGER NOT NULL
);

-- 5. Связь исполнителей и альбомов (M:M)
CREATE TABLE artist_albums (
    artist_id INTEGER NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    album_id INTEGER NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
    PRIMARY KEY (artist_id, album_id)
);

-- 6. Треки (принадлежат одному альбому)
CREATE TABLE tracks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    duration INTEGER NOT NULL,
    album_id INTEGER NOT NULL REFERENCES albums(id) ON DELETE CASCADE
);

-- 7. Сборники
CREATE TABLE collections (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    year INTEGER NOT NULL
);

-- 8. Связь сборников и треков (M:M)
CREATE TABLE collection_tracks (
    collection_id INTEGER NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    track_id INTEGER NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    PRIMARY KEY (collection_id, track_id)
);

-- =============================================
-- ЗАПОЛНЕНИЕ ДАННЫМИ
-- =============================================

-- Жанры
INSERT INTO genres (name) VALUES 
    ('Рок'),
    ('Хип-Хоп'),
    ('Поп-музыка');

-- Исполнители
INSERT INTO artists (name) VALUES 
    ('Linkin Park'),
    ('Kizaru'),
    ('Кравц'),
    ('Анна Асти');

-- Связи исполнителей и жанров
INSERT INTO artist_genres (artist_id, genre_id) VALUES 
    (1, 1),  -- Linkin Park → Рок
    (2, 2),  -- Kizaru → Хип-Хоп
    (3, 2),  -- Кравц → Хип-Хоп
    (3, 3),  -- Кравц → Поп-музыка
    (4, 3);  -- Анна Асти → Поп-музыка


-- Альбомы
INSERT INTO albums (title, year) VALUES 
    ('Meteora', 2003),
    ('TROOPER', 2025),
    ('Soulya man', 2026),
    ('Царица', 2023),
    ('Плачу на техно', 2025);
    
-- Связи исполнителей и альбомов
INSERT INTO artist_albums (artist_id, album_id) VALUES 
    (1, 1),  -- Linkin Park → Meteora
    (2, 2),  -- Kizaru → TROOPER
    (3, 3),  -- Кравц → Soulja man
    (4, 4),  -- Анна Асти → Царица
    (4, 5);  -- Анна Асти → Плачу на техно

-- Треки
INSERT INTO tracks (title, duration, album_id) VALUES 
    ('Somewhere I Belong', 203, 1),
    ('Faint', 162, 1),
    ('Soulja man', 195, 3),
    ('TROOPER', 180, 2),
    ('Царица', 198, 5),
    ('Плачу на техно', 163, 4),
    ('Hit the Floor', 164, 1);

-- Сборники
INSERT INTO collections (name, year) VALUES 
    ('Лучшее за 2025', 2026),
    ('Плейлист дня', 2026),
    ('Топ всех времен', 2025),
    ('100% хит', 2025);

-- Связи сборников и треков
INSERT INTO collection_tracks (collection_id, track_id) VALUES 
    (1, 3), (1, 4), (1, 1), (1, 5),
    (2, 1), (2, 7), (2, 6), (2, 3), 
    (3, 4), (3, 7), (3, 3), (3, 6), 
    (4, 5), (4, 2), (4, 1), (4, 7);

-- =============================================
-- ПРОВЕРОЧНЫЕ ЗАПРОСЫ
-- =============================================

-- Исполнители и их жанры
SELECT a.name AS artist, STRING_AGG(g.name, ', ') AS genres
FROM artists a
JOIN artist_genres ag ON a.id = ag.artist_id
JOIN genres g ON ag.genre_id = g.id
GROUP BY a.id, a.name
ORDER BY a.name;

-- Альбомы и их исполнители
SELECT al.title AS album, al.year, STRING_AGG(ar.name, ', ') AS artists
FROM albums al
JOIN artist_albums aa ON al.id = aa.album_id
JOIN artists ar ON aa.artist_id = ar.id
GROUP BY al.id, al.title, al.year
ORDER BY al.year;

-- Сборники и их треки
SELECT c.name AS collection, c.year, t.title AS track
FROM collections c
JOIN collection_tracks ct ON c.id = ct.collection_id
JOIN tracks t ON ct.track_id = t.id
ORDER BY c.name, t.title;
