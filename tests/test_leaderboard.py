# tests/test_leaderboard.py
# =============================================================
#  TC-11: Public leaderboard
#  Analytics overview
# =============================================================
import pytest


class TestTC11_PublicLeaderboard:

    def test_leaderboard_accessible_without_login(self, client):
        resp = client.get('/api/analytics/leaderboard/1')
        assert resp.status_code == 200

    def test_leaderboard_returns_success_status(self, client):
        resp = client.get('/api/analytics/leaderboard/1')
        assert resp.get_json()['status'] == 'success'

    def test_leaderboard_data_is_list(self, client):
        resp = client.get('/api/analytics/leaderboard/1')
        data = resp.get_json().get('data', [])
        assert isinstance(data, list)

    def test_leaderboard_entry_has_required_fields(self, client, admin_client):
        admin_client.post('/api/scores',
                          json={'match_id': 1, 'team1_score': 3,
                                'team2_score': 1, 'winner_team_id': 1},
                          content_type='application/json')
        resp = client.get('/api/analytics/leaderboard/1')
        data = resp.get_json()['data']
        if data:
            entry = data[0]
            for field in ['team_id', 'wins', 'losses', 'points']:
                assert field in entry

    def test_leaderboard_sorted_by_points(self, client, admin_client):
        admin_client.post('/api/scores',
                          json={'match_id': 1, 'team1_score': 5,
                                'team2_score': 2, 'winner_team_id': 1},
                          content_type='application/json')
        resp   = client.get('/api/analytics/leaderboard/1')
        data   = resp.get_json()['data']
        if len(data) >= 2:
            points = [e['points'] for e in data]
            assert points == sorted(points, reverse=True)

    def test_nonexistent_tournament_returns_404(self, client):
        resp = client.get('/api/analytics/leaderboard/9999')
        assert resp.status_code == 404

    def test_leaderboard_wins_points_consistent(self, client, admin_client):
        admin_client.post('/api/scores',
                          json={'match_id': 1, 'team1_score': 4,
                                'team2_score': 0, 'winner_team_id': 1},
                          content_type='application/json')
        resp = client.get('/api/analytics/leaderboard/1')
        data = resp.get_json()['data']
        for entry in data:
            expected = entry['wins'] * 3 + entry.get('draws', 0) * 1
            assert entry['points'] == expected

    def test_leaderboard_tournament_2(self, client):
        resp = client.get('/api/analytics/leaderboard/2')
        assert resp.status_code == 200

    def test_public_leaderboard_via_certificates(self, client):
        resp = client.get('/api/leaderboard/1')
        assert resp.status_code == 200
        assert 'standings' in resp.get_json()

    def test_leaderboard_standings_is_list(self, client):
        resp      = client.get('/api/leaderboard/1')
        standings = resp.get_json()['standings']
        assert isinstance(standings, list)

    def test_leaderboard_entry_has_team_id(self, client):
        resp      = client.get('/api/leaderboard/1')
        standings = resp.get_json()['standings']
        if standings:
            assert 'team_id' in standings[0]
            assert 'points'  in standings[0]


class TestAnalyticsOverview:

    def test_overview_requires_admin(self, player_client):
        resp = player_client.get('/api/analytics/overview')
        assert resp.status_code == 403

    def test_overview_accessible_to_admin(self, admin_client):
        resp = admin_client.get('/api/analytics/overview')
        assert resp.status_code == 200

    def test_overview_has_chart_data_fields(self, admin_client):
        resp = admin_client.get('/api/analytics/overview')
        data = resp.get_json().get('data', {})
        assert any(key in data for key in [
            'total_players', 'total_teams',
            'total_matches', 'total_tournaments',
            'players', 'teams'
        ])

    def test_overview_status_success(self, admin_client):
        resp = admin_client.get('/api/analytics/overview')
        assert resp.get_json()['status'] == 'success'

    def test_overview_blocked_for_coach(self, coach_client):
        resp = coach_client.get('/api/analytics/overview')
        assert resp.status_code == 403