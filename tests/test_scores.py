# tests/test_scores.py
# =============================================================
#  Score CRUD tests
# =============================================================
import pytest


class TestScores:

    def test_view_scores_as_admin(self, admin_client):
        response = admin_client.get('/scores/')
        assert response.status_code == 200

    def test_add_score(self, admin_client):
        response = admin_client.post('/scores/add', data={
            'team1':  'Team A',
            'team2':  'Team B',
            'score1': 3,
            'score2': 1
        })
        assert response.status_code == 200

    def test_view_scores_as_player(self, player_client):
        response = player_client.get('/scores/')
        assert response.status_code == 200

    def test_add_score_json(self, admin_client):
        resp = admin_client.post('/scores/add',
                                 json={'team1': 'A', 'team2': 'B',
                                       'score1': 1, 'score2': 0},
                                 content_type='application/json')
        assert resp.status_code == 200

    def test_post_score_api(self, admin_client):
        resp = admin_client.post('/api/scores/',
                                 json={'match_id': 10, 'team1_score': 4,
                                       'team2_score': 2, 'winner_team_id': 1},
                                 content_type='application/json')
        assert resp.status_code == 201

    def test_post_score_has_score_id(self, admin_client):
        resp = admin_client.post('/api/scores/',
                                 json={'match_id': 11, 'team1_score': 3,
                                       'team2_score': 0, 'winner_team_id': 1})
        assert 'score_id' in resp.get_json()

    def test_get_api_scores(self, admin_client):
        resp = admin_client.get('/api/scores/')
        assert resp.status_code == 200
        assert 'data' in resp.get_json()

    def test_add_score_unauthorized(self, client):
        resp = client.post('/api/scores/',
                           json={'match_id': 1, 'team1_score': 3,
                                 'team2_score': 1})
        assert resp.status_code == 401

    def test_add_score_via_add_endpoint(self, client):
        resp = client.post('/scores/add', data={
            'match_id': '1', 'team1_score': '2', 'team2_score': '0'
        })
        assert resp.status_code == 200

    def test_scores_data_is_list(self, admin_client):
        resp = admin_client.get('/scores/')
        assert resp.status_code == 200